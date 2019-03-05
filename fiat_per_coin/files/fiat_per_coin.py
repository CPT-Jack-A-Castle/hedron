#!/usr/bin/python3

"""
Maintains an atomic local cache of fiat currency rates.
"""

import logging
import os
import shutil
from time import time

import aaargh
import bitcoinacceptor

BASE_DIR = '/var/cache/fiat_per_coin'

logging.basicConfig(level=logging.INFO)

cli = aaargh.App()


def _hour_is_even():
    epoch = int(time())
    # // is integer divide.
    hours_in_epoch = epoch // 3600
    # If the remainder after dividing by 2 is 0...
    if (hours_in_epoch % 2) == 0:
        return True
    else:
        return False


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

    # bitcoinacceptor's fiat_per_coin returns previous hour's price and
    # previous-to-the-previous hour's price.
    current, previous = bitcoinacceptor.fiat_per_coin(currency=cryptocurrency)
    current_amount = str(current)
    previous_amount = str(previous)

    logging.info('bitcoinacceptor.fiat_per_coin: {}, {}'.format(current,
                                                                previous))

    coin_dir = os.path.join(BASE_DIR, cryptocurrency)
    # If we are even, write to odd. We don't want to break the current price.
    if _hour_is_even():
        output_file = os.path.join(coin_dir, 'odd')
    else:
        output_file = os.path.join(coin_dir, 'even')

    # We use a temporary file and move it over so that the operation is
    # completely atomic.
    temporary_file = output_file + '-new'

    with open(temporary_file, 'w') as fp:
        fp.write(current_amount)

    shutil.move(temporary_file, output_file)

    # If necessary...
    _bootstrap_previous_hour(cryptocurrency, previous_amount)

    return True


def _bootstrap_previous_hour(cryptocurrency, previous_amount):
    """
    There is a condition where the server may be launched and receiving
    requests with the previous hour, which is unavailable
    """
    coin_dir = os.path.join(BASE_DIR, cryptocurrency)
    even_file = os.path.join(coin_dir, 'even')
    odd_file = os.path.join(coin_dir, 'odd')

    # Fill in whichever does not exist.
    if not os.path.exists(even_file):
        output_file = even_file
    elif not os.path.exists(odd_file):
        output_file = odd_file
    else:
        return True

    logging.info('Bootstrapping previous hour.')

    # Atomicity is not an issue here.
    with open(output_file, 'w') as fp:
        fp.write(previous_amount)

    return True


@cli.cmd
@cli.cmd_arg('cryptocurrency')
def get(cryptocurrency):
    """
    Reads our local cache of said cryptocurrency.
    """
    def _read(input_file):
        with open(input_file, 'r') as fp:
            contents = fp.readline()
            return float(contents)

    # FIXME: Ugly
    coin_dir = os.path.join(BASE_DIR, cryptocurrency)
    even_file = os.path.join(coin_dir, 'even')
    odd_file = os.path.join(coin_dir, 'odd')
    if _hour_is_even():
        first = even_file
        second = odd_file
    else:
        first = odd_file
        second = even_file

    first_amount = _read(first)
    second_amount = _read(second)

    return first_amount, second_amount


if __name__ == '__main__':
    output = cli.run()
    if output is True:
        exit(0)
    elif output is False:
        exit(1)
    else:
        print(output)
