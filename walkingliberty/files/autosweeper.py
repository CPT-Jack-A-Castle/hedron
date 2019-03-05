#!/usr/bin/python3

import json
import logging

from walkingliberty import WalkingLiberty

logging.basicConfig(level=logging.INFO)


def get_key():
    # Path comes from hedron.walkingliberty.local_wallet state.
    path = '/etc/walkingliberty/private'
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
    key = get_key()
    walkingliberty = WalkingLiberty(currency)
    balance = walkingliberty.balance(private_key=key)
    logging.debug('Balance is {}'.format(balance))
    if balance > 0:
        return True
    else:
        return False


def sweep(currency):
    key = get_key()
    destination_address = get_config()['addresses'][currency]
    walkingliberty = WalkingLiberty(currency)
    walkingliberty.sweep(private_key=key, address=destination_address)


def autosweep():
    for currency in ['bch', 'btc']:
        if can_sweep(currency):
            logging.info('Balance non-zero, sweeping {}'.format(currency))
            sweep(currency)
        else:
            logging.info('Balance zero, not sweeping {}'.format(currency))


if __name__ == '__main__':
    autosweep()
