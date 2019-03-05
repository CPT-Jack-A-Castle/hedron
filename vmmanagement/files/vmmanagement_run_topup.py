#!/usr/bin/python3

# This one gets ran by root and does the making.

import json
import os
import logging
import shutil

from sporestackv2 import validate

import hedron

logging.basicConfig(level=logging.INFO)

TOPUP_DIRECTORY = '/var/tmp/vmmanagement_topup'

VALID_OPTIONS = ('machine_id',
                 'expiration',
                 'currency',
                 'txid')


def validate_options(options):
    for entry in options:
        if entry not in VALID_OPTIONS:
            raise ValueError('{} invalid option.'.format(entry))
    for entry in VALID_OPTIONS:
        if entry not in options:
            raise ValueError('{} missing option.'.format(entry))
    validate.machine_id(options['machine_id'])
    validate.expiration(options['expiration'])
    return True


def topup(options):
    """
    Topup a VM.
    """
    validate_options(options)

    machine_id = options['machine_id']
    expiration = options['expiration']
    currency = options['currency']
    txid = options['txid']

    vm_data = hedron.virtual_machine_info(options['machine_id'])
    logging.info('Topping up: {}'.format(options['machine_id']))

    vm_data['expiration'] = expiration
    vm_data['currency'] = currency
    vm_data['txid'] = txid

    directory = '/var/tmp/runqemu/{}'.format(machine_id)
    json_file = os.path.join(directory, 'settings.json')
    topup_json_file = json_file + '.topup'
    with open(topup_json_file, 'x') as json_file_fp:
        json.dump(vm_data, json_file_fp)

    # Atomic update.
    shutil.move(topup_json_file, json_file)
    return True


# FIXME: Redundant with vmmanagement_run_create
def file_to_dict(json_file):
    try:
        with open(json_file) as fp:
            return json.load(fp)
    except Exception:
        logging.critical('topup: Issue reading json file.')
        raise


def topup_list():
    topup_list = []
    for json_file in os.listdir(TOPUP_DIRECTORY):
        full_path = os.path.join(TOPUP_DIRECTORY, json_file)
        topup_list.append(full_path)
    return topup_list


def topup_all_the_things():
    topped_up_list = []
    for topmeup in topup_list():
        topped_up_list.append(topup(file_to_dict(topmeup)))
        os.remove(topmeup)
    return topped_up_list


if __name__ == '__main__':
    try:
        output = topup_all_the_things()
    except Exception:
        logging.critical('topup_run failure.')
        raise
    print(output)
