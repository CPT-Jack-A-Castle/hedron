#!/usr/bin/python3

"""
Maintains an atomic local cache of fiat currency rates.
"""

import logging
import os
from time import time

import aaargh
import bitcoinacceptor

BASE_DIR = '/var/cache/fiat_per_coin'

logging.basicConfig(level=logging.INFO)

cli = aaargh.App()


def _prepare(cryptocurrency):
    """
    Makes the necessary directory if needed.
    """
    coin_dir = os.path.join(BASE_DIR, cryptocurrency)
    if not os.path.exists(coin_dir):
        logging.info('Creating {} for {}'.format(coin_dir, cryptocurrency))
        os.mkdir(coin_dir)
    return True


@cli.cmd
@cli.cmd_arg('cryptocurrency')
def update(cryptocurrency):
    """
    Updates our local cache of said cryptocurrency.
    Ideally, called before the next hour, say 55th minute.

    Requires write access to BASE_DIR
    """
    _prepare(cryptocurrency)

    price = bitcoinacceptor.fiat_per_coin(currency=cryptocurrency)

    msg = 'bitcoinacceptor.fiat_per_coin: {} {}'.format(cryptocurrency, price)
    logging.info(msg)

    coin_dir = os.path.join(BASE_DIR, cryptocurrency)
    output_file = os.path.join(coin_dir, str(int(time())))

    with open(output_file, 'w') as fp:
        fp.write(str(price))

    return True


@cli.cmd
@cli.cmd_arg('cryptocurrency')
def get(cryptocurrency):
    """
    Reads our local cache of said cryptocurrency.
    """
    coin_dir = os.path.join(BASE_DIR, cryptocurrency)

    def _read(input_file):
        with open(input_file, 'r') as fp:
            contents = fp.readline()
            return float(contents)

    # Files sorted by last changed.
    # Could also sort by name (epoch) but this is probably easier/faster.
    os.chdir(coin_dir)
    files = sorted(os.listdir(), key=os.path.getctime)

    first_amount = _read(files[-1])
    # In case we aren't bootstrapped with a previous time.
    try:
        second_amount = _read(files[-2])
    except Exception:
        second_amount = first_amount

    return first_amount, second_amount


if __name__ == '__main__':
    output = cli.run()
    if output is True:
        exit(0)
    elif output is False:
        exit(1)
    else:
        print(output)
