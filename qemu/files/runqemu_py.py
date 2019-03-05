#!/usr/bin/python3

import os
import sys
import logging
import time
from shutil import rmtree

import aaargh
import hedron
from sh import systemctl

logging.basicConfig(level=logging.INFO)

# aaargh is deprecated. I investigated click and it did not look suitable. Nor
# did anything else in a 20 minute search. aaargh it is, at least for now.
# docopt *could* be promising.

cli = aaargh.App()


@cli.cmd
@cli.cmd_arg('virtual_machine')
def virtual_machine_exists(virtual_machine):
    """
    Returns True/False depending if it exists or not.
    """
    try:
        hedron.virtual_machine_info(virtual_machine)
    except Exception:
        return False
    return True


# This is not atomic :-/
# Pretty fragile if this happens in the middle of a power outage.
# May need to use more aggressive kill signals with systemctl stop?
@cli.cmd
@cli.cmd_arg('machine_id')
def virtual_machine_destroy(machine_id):
    logging.info('Destroying {}'.format(machine_id))
    systemctl('stop', 'runqemu_start_{}.path'.format(machine_id))
    systemctl('disable', 'runqemu_start_{}.path'.format(machine_id))
    systemctl('stop', 'runqemu_stop_{}.path'.format(machine_id))
    systemctl('disable', 'runqemu_stop_{}.path'.format(machine_id))
    path = '/etc/systemd/system/runqemu_start_{}.path'.format(machine_id)
    os.remove(path)
    path = '/etc/systemd/system/runqemu_stop_{}.path'.format(machine_id)
    os.remove(path)
    runqemu_service = 'runqemu@{}'.format(machine_id)
    systemctl('stop', runqemu_service)
    systemctl('disable', runqemu_service)
    # Not disabling the tornet service anymore, at least for now.
    # If we do add this back, need to be careful to only do it when
    # the VM is in fact using tornet.
    # Another option is carml's newid feature.
    # slot = hedron.virtual_machine_info(machine_id)['slot']
    # tornet_service = 'tornet@1{}'.format(slot)
    # systemctl('stop', tornet_service)
    # systemctl('disable', tornet_service)
    directory = os.path.join('/home/vmmanagement', machine_id)
    rmtree(directory)
    # This is last for a reason.
    rmtree('/var/tmp/runqemu/{}'.format(machine_id))
    return True


@cli.cmd
def list_expired_virtual_machines():
    """
    Lists all expired VMs on the system.
    """
    now = time.time()
    expired_vms = []
    for vm in hedron.list_virtual_machines():
        vm_info = hedron.virtual_machine_info(vm)
        if vm_info['expiration'] != 0:
            # 0 means they never expire.
            if vm_info['expiration'] < now:
                time_delta = int(now - vm_info['expiration'])
                logging.debug('{} expired for {} seconds.'.format(vm,
                                                                  time_delta))
                expired_vms.append(vm)
            else:
                time_delta = int(vm_info['expiration'] - now)
                logging.debug('{} expiring in {} seconds.'.format(vm,
                                                                  time_delta))
    return expired_vms


@cli.cmd
def destroy_expired_virtual_machines():
    """
    Destroy all expired virtual machines.
    """
    expired_vms = list_expired_virtual_machines()
    for expired_vm in expired_vms:
        try:
            virtual_machine_destroy(expired_vm)
        except Exception:
            logging.critical('Failed to destroy expired VM.')
            raise
    return expired_vms


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
