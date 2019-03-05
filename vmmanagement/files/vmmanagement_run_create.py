#!/usr/bin/python3

# This one gets ran by root and does the making.

import json
import os
import logging
import shutil
from hashlib import sha256
from time import sleep

# sh will auto translate qemu_img to qemu-img.
# Python doesn't like dashes in function names.
import sh
from sporestackv2 import validate

import hedron
from vmmanagement_create import (has_sufficient_resources,
                                 get_and_validate_config,
                                 list_available_ipv4s,
                                 CREATION_DIRECTORY)

logging.basicConfig(level=logging.INFO)

VALID_OPTIONS = ('machine_id',
                 'memory',
                 'disk',
                 'cores',
                 'qemuopts',
                 'hostaccess',
                 'ipv4',
                 'ipv6',
                 'bandwidth',
                 'organization',
                 'managed',
                 'expiration',
                 'currency',
                 'txid')


# FIXME: Should have min/max range validation as well?
def validate_options(options):
    for entry in options:
        if entry not in VALID_OPTIONS:
            raise ValueError('{} invalid option.'.format(entry))
    for entry in VALID_OPTIONS:
        if entry not in options:
            raise ValueError('{} missing option.'.format(entry))
    validate.machine_id(options['machine_id'])
    validate.memory(options['memory'])
    validate.disk(options['disk'])
    validate.cores(options['cores'])
    validate.qemuopts(options['qemuopts'])
    validate.hostaccess(options['hostaccess'])
    validate.managed(options['managed'])
    validate.expiration(options['expiration'])
    validate.ipv4(options['ipv4'])
    validate.ipv6(options['ipv6'])
    # Double check to be sure these are equivalent if nat or tor.
    validate.further_ipv4_ipv6(options['ipv4'], options['ipv6'])
    validate.bandwidth(options['bandwidth'])
    validate.organization(options['organization'])
    return True


def is_slot_available(slot):
    """
    Determines if a slot is available.
    """
    for vm in hedron.list_virtual_machines():
        if hedron.virtual_machine_info(vm)['slot'] == slot:
            return False
    return True


def next_available_slot():
    """
    Finds the next available slot.
    Note: This is an extremely inefficient design!
    """
    for slot in range(4000, 4060 + 1):
        if is_slot_available(slot):
            return slot
    raise Exception('All slots used.')


def random_mac():
    """
    Returns a random mac address.

    We start with 00 to prevent from being a multicast address.
    """
    # mac addresses are 48 bits. We want 40 since we are providing the
    # first 8 bytes .
    random_bytes = os.urandom(256)
    # Might help with security to not expose raw random data.
    random_bytes = sha256(random_bytes).digest()
    mac = '00:%02x:%02x:%02x:%02x:%02x' % (random_bytes[1],
                                           random_bytes[2],
                                           random_bytes[3],
                                           random_bytes[4],
                                           random_bytes[5])
    return mac


def _ipv6_postfix(mac):
    """
    Convert from colons every 8 bits to every 16 bits.

    Kinda silly...
    """
    mac = mac.replace(':', '')
    byte_2 = int(mac[1], 16)
    byte_2 = byte_2 ^ 0x02
    byte_2 = '%x' % byte_2
    postfix = '{}{}{}:{}ff:fe{}:{}'.format(mac[0],
                                           byte_2,
                                           mac[2:4],
                                           mac[4:6],
                                           mac[6:8],
                                           mac[8:12])
    return postfix


def mac_to_ipv6(mac):
    """
    Converts a mac address to the stateless IPv6 address it should map to.
    """
    config = get_and_validate_config()
    prefix = config['ipv6_prefix']
    postfix = _ipv6_postfix(mac)
    return prefix + ':' + postfix


def dhcpd_snippet(vm, mac, ipv4):
    """
    DHCPD snippet

    Returns the host portion for fixed IP addresses.
    """
    # We hash the vm name for security concerns.
    vm_hashed = sha256(bytes(vm, 'utf8')).hexdigest()[:10]
    return 'host ' + vm_hashed + ' { hardware ethernet ' + mac + \
           '; fixed-address ' + ipv4 + '; }'


def dhcpd_head():
    with open('/etc/dhcpd-primary.conf.head') as fp:
        head = fp.read()
    return head


def dhcpd_config():
    head = dhcpd_head()
    body = head
    for vm in hedron.list_virtual_machines():
        vm_info = hedron.virtual_machine_info(vm)
        if 'network_interfaces' in vm_info:
            if 'ipv4' in vm_info['network_interfaces'][0]:
                mac = vm_info['network_interfaces'][0]['mac']
                ipv4 = vm_info['network_interfaces'][0]['ipv4']
                body = body + '\n' + dhcpd_snippet(vm, mac, ipv4)
    return body


def set_dhcpd_config(config):
    # os.umask returns the umask as it was before setting it.
    initial_umask = os.umask(0o0077)
    with open('/etc/dhcpd-primary.conf', 'w') as fp:
        fp.write(config)
    # Set back to how it was. May or may not be needed, but probably is.
    os.umask(initial_umask)
    return True


def get_dhcpd_config():
    """
    Returns existing dhcpd.conf or "", if no config file found.
    """
    try:
        with open('/etc/dhcpd-primary.conf') as fp:
            return fp.read()
    except Exception:
        # FIXME: There's a better exception for this...
        return ""


def dhcpd_update_needed():
    should_be = dhcpd_config()
    currently = get_dhcpd_config()
    if currently != should_be:
        return True
    else:
        return False


def update_dhcpd_if_needed():
    """
    Updates dhcpd config and restarts daemon if needed.

    Idempotent function.
    """
    if dhcpd_update_needed():
        set_dhcpd_config(dhcpd_config())
        sh.systemctl('restart', 'dhcpd@primary')

    return True


def tornet(slot):
    """
    Starts/newid's tornet as needed.
    """
    # newid if service is running, enable/start if not.
    # The 1 prefix is intentional.
    tornet_port = '1{}'.format(slot)
    tornet_service = 'tornet@{}'.format(tornet_port)

    # Yuck.
    try:
        sh.systemctl('status', '--no-pager', tornet_service)
        tornet_running = True
    except sh.ErrorReturnCode_3:
        tornet_running = False

    if tornet_running is True:
        carml_path = 'unix:/run/tornet-{}/control'.format(tornet_port)
        # FIXME: We should use carml as an import, not like this.
        sh.carml('-c', carml_path, 'newid')
        return True
    else:
        # Start and enable service. FIXME: enable --now doesn't work?
        sh.systemctl('enable', tornet_service)
        sh.systemctl('start', tornet_service)

        # Wait at most, 300 seconds~ for Tor to come online.
        tries = 1
        while tries < 300:
            tries = tries + 1
            # journalctl doesn't support something like -u service -S
            # started.
            # Instead, we do the best we can and make some reasonable
            # assumptions.
            output = sh.journalctl('--no-pager', '-b', '-S', '1 minute ago',
                                   '-u', tornet_service)
            if 'Bootstrapped 100%' in output:
                return True
            else:
                sleep(1)

        raise ValueError('Tor service failed to start.')


def create(options):
    """
    Create a VM.
    This should be split out into a literal create, taking the same
    kind of arguments as vmmmanagement_create, and the
    dict version like this.
    """
    validate_options(options)
    logging.info('Creating: {}'.format(options['machine_id']))
    # This should never fail. If it fails, it means the customer paid for the
    # VM but we ran out of capacity.
    # Throw a critical log and bail out if it does.
    try:
        has_sufficient_resources(cores=options['cores'],
                                 memory=options['memory'],
                                 disk=options['disk'])
    except Exception:
        logging.critical('vmmanagement_run_create has insufficient resources!')
        raise

    options['network_interfaces'] = [{}]

    # Pick a mac address, if relevant.
    if options['ipv4'] == '/32' or options['ipv6'] == '/128':
        options['network_interfaces'][0]['mac'] = random_mac()

    if options['ipv6'] == '/128':
        mac = options['network_interfaces'][0]['mac']
        options['network_interfaces'][0]['ipv6'] = mac_to_ipv6(mac)

    if options['ipv4'] == '/32':
        mac = options['network_interfaces'][0]['mac']
        options['network_interfaces'][0]['ipv4'] = list_available_ipv4s()[0]

    options['slot'] = next_available_slot()

    options['sshport'] = 22
    # sshhostname and sshport are for if there isn't direct access into the
    # server and it's using the qemu user networking mode.
    if options['ipv4'] in ['tor', 'nat']:
        sshhostnamepath = '/etc/tor/hidden_service_slot_{}/hostname'
        sshhostnamepath = sshhostnamepath.format(options['slot'])
        # In case we aren't using tor-runqemu
        if os.path.exists(sshhostnamepath):
            with open(sshhostnamepath) as fp:
                options['sshhostname'] = fp.readline().strip()
        else:
            options['sshhostname'] = None
    else:
        options['sshhostname'] = options['network_interfaces'][0]['ipv6']
    directory = os.path.join('/var/tmp/runqemu', options['machine_id'])
    # FIXME: Add error logging that can be property sent somewhere and reviewd.
    if os.path.exists(directory):
        raise ValueError('VM already exists.')
    # Make the directory as 0750 so no one but root and vmmanagement can peek.
    os.umask(0o0027)
    os.mkdir(directory)
    shutil.chown(directory, user=None, group='vmmanagement')
    json_file = os.path.join(directory, 'settings.json')
    os.umask(0o0022)
    with open(json_file, 'x') as json_file_fp:
        json.dump(options, json_file_fp)

    if options['disk'] != 0:
        disk_file = os.path.join(directory, 'disk.qcow2')
        disk_size = '{}G'.format(options['disk'])
        os.umask(0o0077)
        # Make the disk file completely locked down.
        sh.qemu_img.create('-f', 'qcow2', disk_file, disk_size)
        os.umask(0o0027)

    # Directory for vmmanagement_shell-based commands.
    directory = os.path.join('/home/vmmanagement', options['machine_id'])
    # We want vmmanagement to be able to touch start and stop.
    os.umask(0o0000)
    os.mkdir(directory)
    # Copy sample ipxe ISO file over so we have something to boot with.
    # This ISO gets replaced by the ipxescript call.
    ipxe_iso_file = os.path.join(directory, 'ipxe.iso')
    shutil.copy('/var/tmp/ipxe_stock.iso', ipxe_iso_file)

    # tornet networking, if needed.
    if options['ipv4'] == 'tor':
        tornet(options['slot'])

    # Finish up with some shell script. Eventually will be converted to
    # Python.
    sh.runqemu_create(options['machine_id'], options['slot'])
    if options['ipv4'] == '/32':
        update_dhcpd_if_needed()
    return True


def file_to_dict(json_file):
    try:
        with open(json_file) as fp:
            return json.load(fp)
    except Exception:
        logging.critical('Issue reading json file.')
        raise


def create_list():
    create_list = []
    for json_file in os.listdir(CREATION_DIRECTORY):
        full_path = os.path.join(CREATION_DIRECTORY, json_file)
        create_list.append(full_path)
    return create_list


def create_all_the_things():
    created_list = []
    for creation in create_list():
        created_list.append(create(file_to_dict(creation)))
        os.remove(creation)
    return created_list


if __name__ == '__main__':
    output = create_all_the_things()
    print(output)
