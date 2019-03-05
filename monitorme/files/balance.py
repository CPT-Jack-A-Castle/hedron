#!/usr/bin/python3

# FIXME: Should support public addresses.

import logging
import os

import statsd as libstatsd
import sh
from walkingliberty import WalkingLiberty

logging.basicConfig(level=logging.INFO)


if os.path.exists('/var/tmp/autorenew_bip32'):
    with open('/var/tmp/autorenew_bip32') as fp:
        bip32 = fp.read()
        bip32 = bip32.strip('\n')
else:
    # Very hacky. Unfortunately, salt is Python 2 and not Python 3.
    # Output is local: wallet
    bip32 = sh.salt_call('--local',
                         '--no-color',
                         '--retcode-passthrough',
                         '--log-file=/dev/null',
                         '--out=txt',
                         'pillar.get',
                         'hedron.walkingliberty')
    bip32 = str(bip32).strip('\n')
    bip32 = bip32.split(' ')[1]


statsd = libstatsd.StatsClient('localhost', 8125)
walkingliberty = WalkingLiberty('bch')
balance = walkingliberty.balance(bip32)
logging.info('Balance: {}'.format(balance))
statsd.gauge('bitcoin.balance', balance)
