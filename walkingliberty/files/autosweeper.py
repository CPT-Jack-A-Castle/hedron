#!/usr/bin/python3

import json
import logging
import os

from walkingliberty import WalkingLiberty

CURRENCIES = ('bch', 'btc', 'bsv')

logging.basicConfig(level=logging.INFO)


def get_key(currency):
    # Path(s) comes from hedron.walkingliberty.local_wallet state.
    # Try the legacy path first, which is one private key for all.
    legacy_path = '/etc/walkingliberty/private'
    path = '/etc/walkingliberty/private_{}'.format(currency)
    if os.path.exists(legacy_path):
        path = legacy_path
    with open(path) as key_file:
        return key_file.read().strip('\n')


def get_config():
    """
    Configuration file is json.

    Looks something like this:
    {"addresses": {"bch": "bitcoincash:qq...", "btc": "1..."}}
    """
    path = '/etc/walkingliberty/autosweeper.json'
    with open(path) as json_fp:
        return json.load(json_fp)


def can_sweep(currency):
    key = get_key(currency)
    walkingliberty = WalkingLiberty(currency)
    balance = walkingliberty.balance(private_key=key)
    logging.debug('Balance is {}'.format(balance))
    if balance > 0:
        return True
    else:
        return False


def sweep(currency):
    key = get_key(currency)
    destination_address = get_config()['addresses'][currency]
    walkingliberty = WalkingLiberty(currency)
    walkingliberty.sweep(private_key=key, address=destination_address)


def autosweep():
    for currency in CURRENCIES:
        if can_sweep(currency):
            logging.info('Balance non-zero, sweeping {}'.format(currency))
            sweep(currency)
        else:
            logging.info('Balance zero, not sweeping {}'.format(currency))


if __name__ == '__main__':
    autosweep()
