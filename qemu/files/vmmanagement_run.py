#!/usr/bin/python3

import sys
import os
import logging

import sh

import hedron

DRIVE = 'file={},format=qcow2,cache=writeback,discard=unmap,'\
        'detect-zeroes=unmap,if=virtio'

# FIXME: '-sandbox on' breaks with non-usermode network.
DEFAULT_QEMUOPTS = '-display none'

BASEDIR = '/home/vmmanagement'


def qemuopts_argument(vm):
    """
    qemuopts is a string, not a list of options.
    """
    vm_info = hedron.virtual_machine_info(vm)
    if vm_info['qemuopts'] is not None:
        return vm_info['qemuopts'].split()
    else:
        return DEFAULT_QEMUOPTS.split()


def drive_argument(vm):
    vm_info = hedron.virtual_machine_info(vm)
    qcow2_path = '/var/tmp/runqemu/{}/disk.qcow2'.format(vm)
    drive_argument = DRIVE.format(qcow2_path)
    if vm_info['disk'] != 0:
        return drive_argument
    else:
        return None


def serial_argument(vm):
    serial_path = BASEDIR + '/{}/serial'.format(vm)
    return 'unix:{},server,nowait'.format(serial_path)


def network_argument(vm):
    """
    Returns the network arguments that qemu will run with, if any.
    """
    vm_info = hedron.virtual_machine_info(vm)
    if vm_info['ipv4'] is False and vm_info['ipv6'] is False:
        return []

    hostaccessargument = ''
    if vm_info['hostaccess'] is True:
        hostaccessargument = ',guestfwd=tcp:10.0.2.1:1-tcp:127.0.0.1:22'

    if vm_info['ipv4'] in ['nat', 'tor'] and vm_info['ipv6'] in ['nat', 'tor']:
        sshport = vm_info['slot']
        network_return = ['-net', 'nic,model=virtio', '-net']
        args = 'user,hostfwd=tcp:127.0.0.1:{}-:22{}'
        network_return.append(args.format(sshport,
                                          hostaccessargument))

    elif vm_info['ipv4'] == '/32' or vm_info['ipv6'] == '/128':
        mac = vm_info['network_interfaces'][0]['mac']
        interface_name = 'slot{}'.format(vm_info['slot'])
        network_return = ['-device', 'virtio-net-pci,netdev='
                          'primary,mac={}'.format(mac),
                          '-netdev', 'tap,id=primary,br=primary,'
                          'ifname={}'.format(interface_name)]

    else:
        raise ValueError('Unsupported network argument combination.')
    return network_return


def ipxe_iso_argument(vm):
    iso_path = BASEDIR + '/{}/ipxe.iso'.format(vm)
    return ['-cdrom', iso_path]


def boot_order_argument(vm):
    vm_info = hedron.virtual_machine_info(vm)
    bootorder = vm_info['bootorder']
    # Hacky... we provide the "n" via the CD drive's iPXE iso
    bootorder = bootorder.replace('n', 'd')
    return ['-boot', 'order={}'.format(bootorder)]


def qemu_arguments(vm):
    vm_info = hedron.virtual_machine_info(vm)
    arguments = []
    arguments.append('-name')
    arguments.append(vm)
    arguments.append('-smp')
    arguments.append(vm_info['cores'])
    arguments.append('-m')
    arguments.append('{}G'.format(vm_info['memory']))
    arguments.append('-cpu')
    arguments.append('kvm64')
    arguments.append('-enable-kvm')
    arguments.append('-nodefaults')
    arguments.append('-monitor')
    arguments.append('none')
    arguments.append('-qmp')
    arguments.append('unix:/run/runqemu@{}/qmp,server,nowait'.format(vm))
    arguments.extend(qemuopts_argument(vm))
    drive = drive_argument(vm)
    if drive is not None:
        arguments.append('-drive')
        arguments.append(drive)
    arguments.append('-serial')
    arguments.append(serial_argument(vm))
    arguments.extend(network_argument(vm))
    arguments.extend(ipxe_iso_argument(vm))
    arguments.extend(boot_order_argument(vm))
    return arguments


def run_qemu(arguments, gid):
    qemu = sh.Command('qemu-system-x86_64')
    os.setgid(gid)
    # Open up umask for serial terminals.
    os.umask(0o0000)
    return qemu(arguments)


def get_gid(vm):
    """
    Logic filtering possible ipv4 and ipv6 options happens above this point.
    """
    vm_info = hedron.virtual_machine_info(vm)
    # If we are using tor, map to the appropriate tornet process.
    if vm_info['ipv4'] == 'tor' or vm_info['ipv6'] == 'tor':
        return vm_info['slot']
    else:
        # 1194 is "openvpn" which is not ran through tor.
        return 1194


def run_vm(vm):
    gid = get_gid(vm)
    arguments = qemu_arguments(vm)
    return run_qemu(arguments, gid)


if __name__ == '__main__':
    output = run_vm(sys.argv[1])
    logging.error(output)
    # Exit 1 if we get to this point?
    exit(1)
