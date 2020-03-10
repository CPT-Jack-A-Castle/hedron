"""
Only requests for VMs to be made, doesn't actually make them.

Also used as a common utils library for now.
"""

import json
import os
import logging
import time
import ipaddress
from collections import namedtuple

import statsd as libstatsd
import bitcoinacceptor
from sporestackv2 import validate, utilities

import hedron
import fiat_per_coin
import settlers_of_cryptotan as settlers

# Potential vulnerability, statsd isn't running and a malicious user launches
# an emulted statsd to steal stats with.
statsd = libstatsd.StatsClient('localhost',
                               8125,
                               prefix='vmmanagement.create.')

CONFIG_FILE = '/etc/vmmanagement.json'

CREATION_DIRECTORY = '/var/tmp/vmmanagement_creation'

# 10% to affiliates
AFFILIATE_RATE = 0.1

# This is more trouble than it's worth, especially for alternative drivers.
# Eventually want to do type checking on known keys, perhaps.
# VALID_CONFIG_OPTIONS = ('currencies',
#                         'settlers_endpoint',
#                         'topup_enabled',
#                         'draining',
#                         'override_code',
#                         'minimum_cents_per_day',
#                         'cents_per_disk_gb',
#                         'cents_per_memory_gb',
#                         'cents_per_core',
#                         'max_days',
#                         'max_disk_gb',
#                         'max_memory_gb',
#                         'max_cores',
#                         'max_cores_per_vm',
#                         'max_memory_per_vm',
#                         'max_disk_per_vm',
#                         'included_bandwidth_per_day_gb',
#                         'cents_per_extra_bandwidth_gb',
#                         'max_extra_bandwidth_per_day_gb',
#                         'kvmpassthrough_whole_host_only',
#                         'ipv4',
#                         'ipv4_start_of_range',
#                         'ipv4_end_of_range',
#                         'ipv6',
#                         'ipv6_prefix')


def validate_config(config):
    """
    validate configuration

    Always returns True for now.
    """
#     for entry in config:
#         if entry not in VALID_CONFIG_OPTIONS:
#             raise ValueError('{} invalid option.'.format(entry))
    return True


def get_config():
    with open(CONFIG_FILE) as json_file:
        config = json.load(json_file)
    if 'monero_rpc' not in config:
        config['monero_rpc'] = None
    return config


def get_and_validate_config():
    config = get_config()
    if 'settlers_business_token' not in config:
        if 'settlement' in config['currencies']:
            token = config['currencies']['settlement']
            config['settlers_business_token'] = token
        else:
            config['settlers_business_token'] = None
    validate_config(config)
    return config


def ipv4_range(start_ip, end_ip):
    start_ip = ipaddress.IPv4Address(start_ip)
    end_ip = ipaddress.IPv4Address(end_ip)
    all_ips = []
    ip = start_ip
    while ip != end_ip + 1:
        all_ips.append(str(ip))
        ip = ip + 1
    return all_ips


def list_allowable_ipv4s():
    config = get_and_validate_config()
    if 'ipv4_start_of_range' not in config:
        return []
    start_ip = config['ipv4_start_of_range']
    end_ip = config['ipv4_end_of_range']
    return ipv4_range(start_ip, end_ip)


def list_ipv4s_in_use():
    in_use = []
    for vm in hedron.list_virtual_machines():
        vm_info = hedron.virtual_machine_info(vm)
        if 'network_interfaces' in vm_info:
            if 'ipv4' in vm_info['network_interfaces'][0]:
                in_use.append(vm_info['network_interfaces'][0]['ipv4'])
    return in_use


def list_available_ipv4s():
    in_use = list_ipv4s_in_use()
    available = []
    for ip in list_allowable_ipv4s():
        if ip not in in_use:
            available.append(ip)
    return available


def get_used_resources():
    """
    Returns all potentially allocated VM resource counts.
    """
    cores = 0
    memory = 0
    disk = 0
    ipv4_addresses = 0
    for vm in hedron.list_virtual_machines():
        vm_info = hedron.virtual_machine_info(vm)
        cores = cores + vm_info['cores']
        memory = memory + vm_info['memory']
        disk = disk + vm_info['disk']
        if vm_info['ipv4'] == '/32':
            ipv4_addresses = ipv4_addresses + 1
    return {'cores': cores,
            'memory': memory,
            'disk': disk,
            'ipv4_addresses': ipv4_addresses}


def get_available_resources():
    """
    Returns currently unallocated resources.
    """
    config = get_and_validate_config()
    used = get_used_resources()
    max_ipv4s = len(list_allowable_ipv4s())
    return_data = {'disk': config['max_disk_gb'] - used['disk'],
                   'memory': config['max_memory_gb'] - used['memory'],
                   'cores': config['max_cores'] - used['cores'],
                   'ipv4_addresses': max_ipv4s - used['ipv4_addresses']}
    return return_data


def has_sufficient_resources(cores, memory, disk):
    """
    Returns True if we have sufficient resources,
    raises Exception() if not.
    """
    available_resources = get_available_resources()
    config = get_and_validate_config()

    if disk > config['max_disk_per_vm']:
        raise ValueError('Too much disk requested.')
    if memory > config['max_memory_per_vm']:
        raise ValueError('Too much memory requested.')
    if cores > config['max_cores_per_vm']:
        raise ValueError('Too many cores requested.')

    # FIXME: This exception needs a better type.
    # Looks like we will have to make our own. There is no resource exceeded
    # exception type, only a warning.
    if disk > available_resources['disk']:
        raise Exception('Insufficient disk.')
    if memory > available_resources['memory']:
        raise Exception('Insufficient memory.')
    if cores > available_resources['cores']:
        raise Exception('Insufficient cores.')

    return True


def override(override_code):
    if override_code is None:
        return False
    config = get_and_validate_config()
    if override_code == config['override_code']:
        return True
    else:
        raise ValueError('Incorrect override_code.')


def days_to_expiration(days, current_expiration=None):
    """
    Converts days to expiration.
    """
    if days == 0:
        # Never expire.
        return 0
    else:
        if current_expiration is None:
            epoch = int(time.time())
            # 30 minutes for free, for losses in API, iPXE builds, etc.
            nice_guy_free_time = 1800
        else:
            epoch = current_expiration
            # You already got your server. No more gibs for you.
            nice_guy_free_time = 0
        expiration = days * 86400 + epoch + nice_guy_free_time
        return expiration


def launch_vm(creation_data):
    """
    All security checks passed, payment processed.
    Time to tell the host to launch the VM.
    """
    directory = CREATION_DIRECTORY
    machine_id = creation_data['machine_id']
    json_path = os.path.join(directory, '{}.json'.format(machine_id))
    with open(json_path, 'x') as json_file:
        json.dump(creation_data, json_file)
    return True


def launch_vm_and_wait(creation_data):
    launch_vm(creation_data)
    machine_id = creation_data['machine_id']
    settings_path = '/var/tmp/runqemu/{}/settings.json'.format(machine_id)
    # Up to 90 seconds for tor daemon to come alive, if need be.
    # FIXME: way too long if not using tor.
    for tries in range(1, 90 + 1):
        if virtual_machine_exists(machine_id):
            with open(settings_path) as fp:
                created_dict = json.load(fp)
            return created_dict
        time.sleep(1)
    logging.critical('VM creation failed for {}'.format(machine_id))
    raise Exception('Fatal error, VM creation failed.')


def virtual_machine_running(machine_id):
    """
    This is non-fatal.
    """
    directory = '/home/vmmanagement/serial'
    serial_file = os.path.join(directory, machine_id)
    if os.path.exists(serial_file):
        return True
    else:
        return False


def virtual_machine_exists(machine_id):
    """
    This is non-fatal.
    FIXME: We don't handle failure cases well where it creates
    the directory but no further.
    """
    directory = '/home/vmmanagement'
    # We use the 'created' file as it's made last to signal the VM
    # has been created successfully. The directory will come sooner
    # and it's possible there may be another failure before then.
    created_file = os.path.join(directory, machine_id, 'created')
    if os.path.exists(created_file):
        return True
    else:
        return False


def existing_txids(currency):
    """
    Returns a list of txids already used for payment.
    This helps prevent a form of double spends.
    """
    txids = []

    if currency == 'settlement':
        return txids

    for vm in hedron.list_virtual_machines():
        vm_info = hedron.virtual_machine_info(vm)

        if 'txid' not in vm_info:
            continue

        # Legacy support. 2019-08-05
        if isinstance(vm_info['txid'], str):
            txids.append(vm_info['txid'])
        elif isinstance(vm_info['txid'], list):
            for txid in vm_info['txid']:
                txids.append(txid)

    return txids


def bandwidth_calculator(bandwidth, override=False):
    """
    Returns granted bandwidth and bandwidth cost (per day).
    """
    config = get_and_validate_config()
    included_bandwidth = config['included_bandwidth_per_day_gb']
    max_extra_bandwidth = config['max_extra_bandwidth_per_day_gb']
    cents_per_extra_bandwidth = config['cents_per_extra_bandwidth_gb']
    if included_bandwidth == -1:
        return included_bandwidth, 0
    elif bandwidth == 0:
        return 0, 0
    elif bandwidth == -1:
        if override is False:
            raise ValueError('Unlimited bandwidth (-1) not supported.')
        else:
            return -1, 0
    if included_bandwidth >= bandwidth:
        return included_bandwidth, 0
    else:
        extra_bandwidth = bandwidth - included_bandwidth
        if extra_bandwidth > max_extra_bandwidth:
            raise ValueError('Too much bandwidth requested.')
        else:
            cents = extra_bandwidth * cents_per_extra_bandwidth
            return bandwidth, cents


def cost_in_cents(days,
                  cores,
                  memory,
                  disk,
                  ipv4,
                  ipv6,
                  bandwidth,
                  override=False):
    """
    Returns the cost of a server in cents.
    """
    if override is True:
        return 0
    config = get_and_validate_config()
    per_day = cores * config['cents_per_core']
    per_day = memory * config['cents_per_memory_gb'] + per_day
    per_day = disk * config['cents_per_disk_gb'] + per_day
    _, bandwidth_cents = bandwidth_calculator(bandwidth)
    per_day = bandwidth_cents + per_day
    if ipv4 is not False:
        per_day = config['ipv4'][ipv4] + per_day
    if ipv6 is not False:
        per_day = config['ipv6'][ipv6] + per_day
    # We may be working with floats before this point.
    total_cents = int(per_day * days)
    if total_cents < config['minimum_cents_per_day'] * days:
        total_cents = config['minimum_cents_per_day'] * days
    return total_cents


@statsd.timer('payment')
def payment(machine_id,
            currency,
            cents,
            address,
            existing_txids=[],
            settlers_endpoint=None,
            settlers_customer_token=None,
            settlers_business_token=None,
            monero_rpc=None,
            affiliate_token=None,
            affiliate_amount=None):
    """
    Return txid (None or string), amount (in Satoshis or cents, depending).
    """
    output = namedtuple('pay', ['txid', 'amount', 'uri', 'usd', 'address'])

    original_cents = cents
    if affiliate_amount is not None:
        cents += affiliate_amount

    output.usd = utilities.cents_to_usd(cents)

    # Make sure affiliate token is valid if we have one.
    if affiliate_token is not None:
        token_enabled = settlers.deposit_only_token_enabled
        token_enabled(business_token=settlers_business_token,
                      deposit_token=affiliate_token,
                      endpoint=settlers_endpoint)

    if currency == 'settlement':
        output.address = None
        # If this fails, it throws an exception and we bail out.
        settlers.subtract(amount=cents,
                          business_token=settlers_business_token,
                          customer_token=settlers_customer_token,
                          endpoint=settlers_endpoint)

        output.txid = 'settlement'
        output.amount = cents
        output.uri = None
    else:
        output.address = address
        first, second = fiat_per_coin.get(currency)
        # machine_id gets hashed as the unique so it should be safe.
        btcacceptor = bitcoinacceptor.fiat_payment(address=address,
                                                   cents=cents,
                                                   unique=machine_id,
                                                   currency=currency,
                                                   first_price=first,
                                                   second_price=second,
                                                   txids=existing_txids,
                                                   monero_rpc=monero_rpc)
        output.txid = btcacceptor.txid
        output.amount = btcacceptor.satoshis
        output.uri = btcacceptor.uri
        msg = 'payment() attempt: URI: {} Cents: {} Affiliate: {} USD: {}'
        formatted = msg.format(output.uri, cents, affiliate_amount, output.usd)
        logging.info(formatted)
        if btcacceptor.txid is False:
            output.txid = None
        else:
            # If payment was successful...
            if affiliate_token is not None:
                if affiliate_amount is None:
                    affiliate_amount = int(cents * AFFILIATE_RATE)
                try:
                    settlers.deposit(amount=affiliate_amount,
                                     business_token=settlers_business_token,
                                     deposit_token=affiliate_token,
                                     endpoint=settlers_endpoint)
                except Exception as e:
                    logging.critical("Exception paying affiliate.")
                    logging.critical(e)
                    msg = "vmmanagement_create.py payment(): "
                    msg += "Unable to pay affiliate, please try again."
                    # If affiliate fails we want to give a 500 so the client
                    # retries.
                    raise Exception(msg)
                statsd.gauge('payment.affiliate.cents',
                             affiliate_amount,
                             delta=True)

            # Log cents and affiliate cents independently.
            statsd.gauge('payment.cents.{}'.format(currency),
                         original_cents,
                         delta=True)
            statsd.gauge('payment.all_cents.{}'.format(currency),
                         cents,
                         delta=True)

    return output


@statsd.timer('virtual_machine_create')
def virtual_machine_create(machine_id,
                           days,
                           currency,
                           cores=1,
                           memory=1,
                           disk=10,
                           ipv4=False,
                           ipv6=False,
                           bandwidth=10,
                           refund_address=None,
                           organization=None,
                           override_code=None,
                           qemuopts=None,
                           managed=False,
                           hostaccess=False,
                           kvmpassthrough=False,
                           wholehost=False,
                           settlement_token=None,
                           affiliate_token=None,
                           affiliate_amount=None):
    config = get_and_validate_config()
    if not override(override_code):
        if config['draining'] is True:
            raise ValueError('Host is draining, unavailable for new builds')
    # Help prevent double buys, etc. We don't need this on topup.
    # We use os.access to facilitate working tests ran as a non-root user.
    if os.access(CREATION_DIRECTORY, os.R_OK):
        if len(os.listdir(CREATION_DIRECTORY)) != 0:
            logging.critical('VM creation already in progress???')
            raise Exception('VM creation already in progress, please retry.')
    return_data = {'latest_api_version': 2,
                   'payment': {'address': None, 'amount': 0},
                   'refund_tx': None,
                   'created': False,
                   'paid': False,
                   'warning': None,
                   'expiration': 1,
                   'txid': None}
    validate.machine_id(machine_id)
    validate.disk(disk)
    validate.cores(cores)
    validate.memory(memory)
    validate.qemuopts(qemuopts)
    validate.managed(managed)
    validate.hostaccess(hostaccess)
    validate.refund_address(refund_address)
    validate.currency(currency)
    validate.ipv4(ipv4)
    validate.ipv6(ipv6)
    validate.bandwidth(bandwidth)
    validate.organization(organization)
    validate.affiliate_amount(affiliate_amount)
    # settlement_token is validated in settlers.
    if virtual_machine_exists(machine_id):
        raise ValueError('machine_id is already in use.')

    if not override(override_code):
        if currency not in config['currencies']:
            # If we just send config['currencies'], we can expose settlement
            # business tokens.
            currencies = []
            for currency in config['currencies']:
                currencies.append(currency)
            msg = 'currency must be one of: {}'.format(currencies)
            raise ValueError(msg)
        if qemuopts is not None:
            message = 'qemuopts must be None unless override_code is set.'
            raise ValueError(message)
        if hostaccess is not False:
            message = 'hostaccess must be False unless override_code is set.'
            raise ValueError(message)
    else:
        return_data['paid'] = True

    if config['kvmpassthrough_whole_host_only'] is True:
        if kvmpassthrough is True:
            if wholehost is not True:
                message = 'kvmpassthrough requires wholehost.'
                raise ValueError(message)

    has_sufficient_resources(cores=cores, memory=memory, disk=disk)
    validate.days(days, zero_allowed=True)
    if days == 0:
        if not override(override_code):
            raise ValueError('days cannot be 0 without override_code.')

    # Currently has no effect over 28 days.
    max_days = config['max_days']
    if days > max_days:
        message = 'host does not allow more than {} days.'.format(max_days)
        raise ValueError(message)

    if bandwidth == 0:
        if ipv4 is not False:
            raise ValueError('bandwidth cannot be 0 without ipv4 set to False')
        if ipv6 is not False:
            raise ValueError('bandwidth cannot be 0 without ipv6 set to False')

    if ipv4 is False:
        if ipv6 is False:
            if bandwidth != 0:
                message = 'bandwidth must be 0 with ipv4 and ipv6 set to False'
                raise ValueError(message)

    if ipv4 is not False:
        if ipv4 not in config['ipv4']:
            raise ValueError('That ipv4 option is not supported.')

    if ipv6 is not False:
        if str(ipv6) not in config['ipv6']:
            raise ValueError('That ipv6 option is not supported.')

    validate.further_ipv4_ipv6(ipv4, ipv6)

    bandwidth_per_day, _ = bandwidth_calculator(bandwidth,
                                                override(override_code))

    if bandwidth_per_day != -1:
        granted_bandwidth = bandwidth_per_day * days
    else:
        granted_bandwidth = -1

    if return_data['paid'] is False:
        address = config['currencies'][currency]
        cents = cost_in_cents(days=days,
                              cores=cores,
                              memory=memory,
                              disk=disk,
                              ipv4=ipv4,
                              ipv6=ipv6,
                              bandwidth=bandwidth,
                              override=override(override_code))
        token = settlement_token
        business_token = config['settlers_business_token']
        pay = payment(machine_id,
                      currency,
                      cents,
                      address,
                      existing_txids=existing_txids(currency),
                      settlers_endpoint=config['settlers_endpoint'],
                      settlers_customer_token=token,
                      settlers_business_token=business_token,
                      monero_rpc=config['monero_rpc'],
                      affiliate_token=affiliate_token,
                      affiliate_amount=affiliate_amount)
        return_data['txid'] = pay.txid
        return_data['payment']['amount'] = pay.amount
        return_data['payment']['uri'] = pay.uri
        return_data['payment']['usd'] = pay.usd
        return_data['payment']['address'] = pay.address

        if return_data['txid'] is not None:
            return_data['paid'] = True

    expiration = days_to_expiration(days)
    creation_data = {'machine_id': machine_id,
                     'memory': memory,
                     'disk': disk,
                     'cores': cores,
                     'ipv4': ipv4,
                     'ipv6': ipv6,
                     'bandwidth': granted_bandwidth,
                     'organization': organization,
                     'qemuopts': qemuopts,
                     'hostaccess': hostaccess,
                     'managed': managed,
                     'expiration': expiration,
                     'currency': currency,
                     'txid': [return_data['txid']]}
    return_data['expiration'] = expiration
    return_data['bandwidth'] = granted_bandwidth
    if return_data['paid'] is True:
        # Should we just merge this dict with return_data?
        created_dict = launch_vm_and_wait(creation_data)
        return_data['network_interfaces'] = created_dict['network_interfaces']
        return_data['sshhostname'] = created_dict['sshhostname']
        return_data['sshport'] = created_dict['sshport']
        # Only show slot if using override.
        if override(override_code):
            return_data['slot'] = created_dict['slot']
        return_data['created'] = True

    # created and paid should always be the same, True or False.
    return return_data
