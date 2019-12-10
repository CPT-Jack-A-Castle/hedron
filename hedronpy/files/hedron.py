import os
import json

import statsd as libstatsd

statsd = libstatsd.StatsClient('localhost', 8125)

VM_DIR = '/var/tmp/runqemu'


def list_virtual_machines():
    virtual_machines = []
    for entry in os.listdir(VM_DIR):
        if os.path.isdir(os.path.join(VM_DIR, entry)):
            virtual_machines.append(entry)
    statsd.gauge('virtual_machine_count', len(virtual_machines))
    return virtual_machines


def validate_bootorder(bootorder):
    if not isinstance(bootorder, str):
        raise TypeError('bootorder must be string.')
    if bootorder not in ['nc', 'cn', 'n', 'c']:
        raise ValueError('Boot order invalid!')
    return True


def virtual_machine_info(machine_id):
    vm_dir = os.path.join(VM_DIR, machine_id)
    if os.path.exists(vm_dir) is not True:
        raise ValueError('VM does not exist on this host.')
    settings_file = os.path.join(VM_DIR, machine_id, 'settings.json')
    with open(settings_file) as virtual_machine_json_file:
        virtual_machine_dict = json.load(virtual_machine_json_file)
    # Also return the user-settable configuration for the VM.
    # FIXME: We need to send an urgent alert if the bootorder
    # is invalid as it indicates a security issue.
    directory = os.path.join('/home', 'vmmanagement', machine_id)
    bootorder_file = os.path.join(directory, 'bootorder')
    length = os.path.getsize(bootorder_file)
    # Allow for one or two characters, with or without a newline.
    if length > 3 or length < 1:
        raise ValueError('Boot order file has invalid length!')
    with open(bootorder_file, 'r') as bootorder_file:
        bootorder = bootorder_file.read().strip('\n')
    validate_bootorder(bootorder)
    virtual_machine_dict['bootorder'] = bootorder
    return virtual_machine_dict


def latest_only(backup_worthy_files):
    """
    For brainvault-persistence.
    """
    latest_archives = {}
    for file in backup_worthy_files:
        # Tenth epoch, not real epoch.
        brainvault_hashed, epoch = file.split('.')[0].split('-')
        # Make it an int so we can sort it more easily.
        epoch = int(epoch[:-1])
        if brainvault_hashed not in latest_archives:
            latest_archives[brainvault_hashed] = []
        latest_archives[brainvault_hashed].append(file)
    finished_list = []
    for brainvault_hashed in latest_archives:
        max_file = max(latest_archives[brainvault_hashed])
        finished_list.append(max_file)
    return finished_list
