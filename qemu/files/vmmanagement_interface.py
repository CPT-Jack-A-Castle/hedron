#!/usr/bin/python3

import sys

import aaargh
import sh

import hedron

cli = aaargh.App()


@cli.cmd
@cli.cmd_arg('slot')
def slot_to_vm(slot):
    """
    Resolves a "slot40XX" to a VM ID.
    """
    if len(slot) != 8:
        raise ValueError('slot argument must be 8 characters.')

    slot = int(slot[4:])

    our_vm = None
    for vm in hedron.list_virtual_machines():
        vm_info = hedron.virtual_machine_info(vm)
        if vm_info['slot'] == slot:
            our_vm = vm
            break

    if our_vm is None:
        raise ValueError('VM does not exist for that slot.')
    else:
        return our_vm


def ebtables_arguments(vm, up=True):
    """
    Returns the network arguments that qemu will run with, if any.

    For now, this primarily just filters mac address on output
    and ethertypes on both.
    """
    vm_info = hedron.virtual_machine_info(vm)

    mac = vm_info['network_interfaces'][0]['mac']
    interface = 'slot{}'.format(vm_info['slot'])

    # Insert if we are bringing the interface up, delete if bringing it down.
    if up is True:
        mode = '-A'
    else:
        mode = '-D'

    # FIXME: Too much redundancy
    # First is IPv4 and IPv6, second is IPv6 only.
    # --concurrent helps keep things stable. Can get weird rule ordering,
    # maybe duplicates without.
    if vm_info['ipv4'] == '/32':
        ebtables = ((mode, 'FORWARD', '-i', interface, '-s', mac, '-p', 'IPv4',
                     '-j', 'ACCEPT', '--concurrent'),
                    (mode, 'FORWARD', '-i', interface, '-s', mac, '-p', 'IPv6',
                     '-j', 'ACCEPT', '--concurrent'),
                    (mode, 'FORWARD', '-i', interface, '-s', mac, '-p', 'ARP',
                     '-j', 'ACCEPT', '--concurrent'),
                    (mode, 'FORWARD', '-i', interface, '-j', 'DROP',
                     '--concurrent'),
                    (mode, 'OUTPUT', '-o', interface, '-p', 'IPv4', '-j',
                     'ACCEPT', '--concurrent'),
                    (mode, 'OUTPUT', '-o', interface, '-p', 'IPv6', '-j',
                     'ACCEPT', '--concurrent'),
                    (mode, 'OUTPUT', '-o', interface, '-p', 'ARP', '-j',
                     'ACCEPT', '--concurrent'),
                    (mode, 'OUTPUT', '-o', interface, '-j', 'DROP',
                     '--concurrent'))
    else:
        ebtables = ((mode, 'FORWARD', '-i', interface, '-s', mac, '-p', 'IPv6',
                     '-j', 'ACCEPT', '--concurrent'),
                    (mode, 'FORWARD', '-i', interface, '-j', 'DROP',
                     '--concurrent'),
                    (mode, 'OUTPUT', '-o', interface, '-p', 'IPv6', '-j',
                     'ACCEPT', '--concurrent'),
                    (mode, 'OUTPUT', '-o', interface, '-j', 'DROP',
                     '--concurrent'))

    return ebtables


def run_ebtables(list_of_arguments):
    for arguments in list_of_arguments:
        sh.ebtables(arguments)
    return True


def _route_command(method, ip):
    ip = ip + '/128'
    return ('ro', method, ip, 'dev', 'primary')


def validate_method(method):
    valid_methods = ['add', 'del']
    if method not in valid_methods:
        raise ValueError('method must be one of: {}'.format(valid_methods))


def route(method, vm):
    """
    Not needed if using primary is bridged with the public interface,
    but doesn't hurt, either.
    """
    validate_method(method)
    vm_info = hedron.virtual_machine_info(vm)
    ip6 = vm_info['network_interfaces'][0]['ipv6']
    arguments = _route_command(method, ip6)
    sh.ip(arguments)
    return True


def _default_route_parse(ip_ro_output):
    """
    Example:
    default via fe80::2 dev eth0 proto ra metric 1024

    Returns device the default router is connected with.
    """
    for line in ip_ro_output.splitlines():
        words = line.split(' ')
        if words[0] == 'default':
            return words[4]


def get_default_v6_route_device():
    ip_ro_output = sh.ip('-6', 'ro')
    device = _default_route_parse(ip_ro_output)
    return device


def ndp_proxy(method, vm):
    validate_method(method)
    vm_info = hedron.virtual_machine_info(vm)
    ip6 = vm_info['network_interfaces'][0]['ipv6']
    device = get_default_v6_route_device()

    sh.ip('-6', 'neigh', method, 'proxy', ip6, 'dev', device)
    return True


@cli.cmd
@cli.cmd_arg('vm')
def up(vm):
    run_ebtables(ebtables_arguments(vm, up=True))
    route('add', vm)
    ndp_proxy('add', vm)
    return True


@cli.cmd
@cli.cmd_arg('vm')
def down(vm):
    run_ebtables(ebtables_arguments(vm, up=False))
    route('del', vm)
    ndp_proxy('del', vm)
    return True


if __name__ == '__main__':
    output = cli.run()
    if output is True:
        sys.exit(0)
    elif output is False:
        sys.exit(1)
    elif output is None:
        sys.exit(0)
    elif isinstance(output, bytes):
        sys.stdout.buffer.write(output)
    else:
        print(output)
