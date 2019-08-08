#!/usr/bin/python3 -EB

import logging
import json

import aaargh
import statsd as libstatsd
from walkingliberty import WalkingLiberty

CONFIG_FILE = '/etc/balance.json'

cli = aaargh.App()
logging.basicConfig(level=logging.INFO)


@cli.cmd
@cli.cmd_arg('--config_file', type=str, default=CONFIG_FILE)
def get_config(config_file=CONFIG_FILE):
    """
    Returns and validates the config.
    """
    with open(config_file) as fp:
        config = json.load(fp)

    for item in config:
        if len(item) != 2:
            raise ValueError("Invalid configuration")
        if 'currency' not in item:
            raise ValueError("Invalid configuration")
        if 'address' not in item:
            raise ValueError("Invalid configuration")

    return config


@cli.cmd
@cli.cmd_arg('currency')
@cli.cmd_arg('address')
def balance(currency, address):
    statsd = libstatsd.StatsClient('localhost', 8125)
    walkingliberty = WalkingLiberty(currency, wallet_mode='address')
    balance = walkingliberty.balance(address)
    logging.info('Balance for {} on {}: {}'.format(address, currency, balance))
    statsd.gauge('balance.{}.{}'.format(currency, address), balance)

    balance_usd = float(walkingliberty.balance(address, unit="usd"))
    msg = 'USD balance for {} on {}: {}'.format(address, currency, balance_usd)
    logging.info(msg)
    statsd.gauge('balance_usd.{}.{}'.format(currency, address), balance_usd)


@cli.cmd
@cli.cmd_arg('--config_file', type=str, default=CONFIG_FILE)
def balance_all(config_file=CONFIG_FILE):
    config = get_config(config_file)
    for pair in config:
        balance(currency=pair['currency'],
                address=pair['address'])


if __name__ == '__main__':
    output = cli.run()
    if output is not None:
        print(output)
