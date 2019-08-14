"""

vmmanagement HTTP implementation for baremetal.

"""

import logging
import traceback

import hug
import ipxeplease
import statsd as libstatsd
from falcon import HTTP_400, HTTP_415, HTTP_500
from sporestackv2 import validate

import vmmanagement_create
import vmmanagement_client_ssh as vmmanagement_client
from vmmanagement_topup import virtual_machine_topup


logging.basicConfig(level=logging.INFO)

statsd = libstatsd.StatsClient('localhost', 8125)

LOCALHOST = '127.0.0.1'

# Should not end with a /
IPXEPLEASE_ENDPOINT = 'http://localhost'


def operating_systems(endpoint=IPXEPLEASE_ENDPOINT):
    return ipxeplease.operating_systems(endpoint=endpoint)


def ipxe(operating_system, ssh_key, endpoint=IPXEPLEASE_ENDPOINT):
    return ipxeplease.ipxe(operating_system=operating_system,
                           ssh_key=ssh_key,
                           endpoint=endpoint)


@hug.get('/host_info', versions=2)
def host_info():
    """
    Info on the host
    """
    config = vmmanagement_create.get_and_validate_config()
    available_resources = vmmanagement_create.get_available_resources()

    def _dict_to_list(dictionary):
        our_list = []
        for item in dictionary:
            our_list.append(item)
        return our_list

    currencies = _dict_to_list(config['currencies'])
    ipv4 = _dict_to_list(config['ipv4'])
    ipv6 = _dict_to_list(config['ipv6'])

    return_dict = {'cores': available_resources['cores'],
                   'memory': available_resources['memory'],
                   'disk': available_resources['disk'],
                   'ipv4_addresses': available_resources['ipv4_addresses'],
                   'currencies': currencies,
                   'ipv4': ipv4,
                   'ipv6': ipv6,
                   'draining': config['draining'],
                   'topup_enabled': config['topup_enabled'],
                   'max_cores_per_vm': config['max_cores_per_vm'],
                   'max_disk_per_vm': config['max_disk_per_vm'],
                   'max_memory_per_vm': config['max_memory_per_vm'],
                   'max_days': config['max_days'],
                   'operating_systems': operating_systems(),
                   'features': ['ipxe', 'operating_system']}

    return return_dict


def validate_extra_ssh_and_os(ssh_key, operating_system):
    if ssh_key is None and operating_system is None:
        return True
    if ssh_key is None or operating_system is None:
        msg = 'ssh_key and operating_system must both be string or null.'
        raise ValueError(msg)
    return True


@hug.post('/launch', versions=2)
def launch(machine_id,
           currency,
           cores,
           memory,
           disk,
           ipv4,
           ipv6,
           bandwidth,
           ipxescript,
           region=None,
           operating_system=None,
           ssh_key=None,
           want_topup=False,
           host=None,
           organization=None,
           days=0,
           settlement_token=None,
           override_code=None,
           hostaccess=False,
           refund_address=None,
           qemuopts=None,
           managed=False):
    """
    ssh_key and operating_system have no effect.
    """
    statsd.incr('vmmanagement_baremetal.launch')

    validate.ipv4(ipv4)
    validate.ipv6(ipv6)
    validate.bandwidth(bandwidth)
    validate.cores(cores)
    validate.disk(disk)
    validate.memory(memory)
    validate.organization(organization)
    validate.machine_id(machine_id)

    validate.ipxescript(ipxescript)
    validate.region(region)

    validate.ssh_key(ssh_key)
    validate.operating_system(operating_system)

    validate_extra_ssh_and_os(ssh_key=ssh_key,
                              operating_system=operating_system)

    os_list = operating_systems()
    if operating_system is not None:
        if operating_system not in os_list:
            msg = 'operating_system must be one of {} on this host'
            msg = msg.format(os_list)
            raise ValueError(msg)

    if operating_system is None and ipxescript is None:
        msg = 'operating_system and ssh_key must be set, and/or ipxescript'
        raise ValueError(msg)

    if region is not None:
        raise ValueError('Only None region supported for this host.')

    def create_vm():
        create = vmmanagement_create.virtual_machine_create
        return create(machine_id=machine_id,
                      days=days,
                      memory=memory,
                      disk=disk,
                      cores=cores,
                      ipv4=ipv4,
                      ipv6=ipv6,
                      bandwidth=bandwidth,
                      currency=currency,
                      refund_address=refund_address,
                      override_code=override_code,
                      settlement_token=settlement_token,
                      qemuopts=qemuopts,
                      managed=managed,
                      organization=organization,
                      hostaccess=hostaccess)

    created_dict = create_vm()
    # paid and created should always be the same.
    if created_dict['paid'] is True:
        if vmmanagement_client.exists(LOCALHOST, machine_id) is not True:
            raise Exception('VM created but does not exist??')
        if ipxescript is None:
            ipxe_output = ipxe(operating_system=operating_system,
                               ssh_key=ssh_key)
            ipxescript = ipxe_output['script']
            created_dict['generated_ipxescript'] = ipxe_output['script']
            created_dict['root_password'] = ipxe_output['root_password']
        vmmanagement_client.ipxescript(LOCALHOST, machine_id, ipxescript)
        vmmanagement_client.start(LOCALHOST, machine_id)

    created_dict['host'] = host
    created_dict['machine_id'] = machine_id

    return created_dict


@hug.post('/topup', versions=2)
def topup(machine_id,
          days,
          currency,
          host=None,
          settlement_token=None,
          refund_address=None,
          override_code=None):
    """
    tops up an existing vm.
    """
    validate.machine_id(machine_id)
    validate.days(days)
    validate.currency(currency)
    validate.refund_address(refund_address)

    topup_dict = virtual_machine_topup(machine_id=machine_id,
                                       days=days,
                                       currency=currency,
                                       refund_address=refund_address,
                                       settlement_token=settlement_token,
                                       override_code=override_code)
    topup_dict['machine_id'] = machine_id
    return topup_dict


@hug.get('/info', versions=2)
def info(machine_id, host=None):
    """
    Info on the VM
    """
    validate.machine_id(machine_id)
    return vmmanagement_client.info(LOCALHOST, machine_id)


@hug.get('/status', versions=2)
def status(machine_id, host=None):
    """
    Checks if the VM is started or stopped.
    """
    output = {}
    validate.machine_id(machine_id)
    output['result'] = vmmanagement_client.status(LOCALHOST, machine_id)
    return output


@hug.get('/exists', versions=2)
def exists(machine_id, host=None):
    """
    Checks if the VM exists.
    """
    output = {}
    validate.machine_id(machine_id)
    output['result'] = vmmanagement_client.exists(LOCALHOST, machine_id)
    return output


@hug.post('/start', versions=2)
def start(machine_id, host=None):
    """
    Boots the VM.
    """
    validate.machine_id(machine_id)
    return vmmanagement_client.start(LOCALHOST, machine_id)


@hug.post('/stop', versions=2)
def stop(machine_id, host=None):
    """
    Immediately kills the VM.
    """
    validate.machine_id(machine_id)
    return vmmanagement_client.stop(LOCALHOST, machine_id)


@hug.post('/ipxescript', versions=2)
def ipxescript(machine_id, ipxescript, host=None):
    """
    Updates iPXE script for VM.
    """
    validate.machine_id(machine_id)
    return vmmanagement_client.ipxescript(LOCALHOST,
                                          machine_id,
                                          ipxescript=ipxescript)


@hug.post('/bootorder', versions=2)
def bootorder(machine_id, bootorder, host=None):
    validate.machine_id(machine_id)
    return vmmanagement_client.bootorder(hostname=LOCALHOST,
                                         machine_id=machine_id,
                                         bootorder=bootorder)


@hug.post('/delete', versions=2)
def delete(machine_id, host=None):
    validate.machine_id(machine_id)
    logging.info('Delete request for: {}'.format(machine_id))
    raise NotImplementedError('Not implemented')


@hug.exception(NotImplementedError)
def hug_handle_not_implemented_exception(exception, response):
    response.status = HTTP_415
    logging.warning(exception)
    return str(exception)


@hug.exception(ValueError)
@hug.exception(TypeError)
def hug_handle_exception(exception, response):
    response.status = HTTP_400
    logging.warning(exception)
    return str(exception)


@hug.exception(Exception)
def hug_handle_other_exceptions(exception, response):
    # 500s for these, since likely our failure and client should retry.
    response.status = HTTP_500
    logging.critical('Unhandled exception in vmmanagement_baremetal!')
    logging.warning(exception)
    traceback.print_exc()
    return "Something broke, please contact us."
