#!/usr/bin/python3

import logging
import sys

import requests

DEFAULT_TIMEOUT = 10
TOR_TIMEOUT = 60


def probe(endpoint):
    """
    Hits endpoint over HTTP.

    If we have any issues, make a critical log.
    """
    url = 'http://{}'.format(endpoint)

    # Use 127.0.0.1:9050 as a SOCKS proxy if connecting to a .onion.
    if endpoint.endswith('.onion') is True:
        proxies = {'http': 'socks5://127.0.0.1:9050'}
        timeout = TOR_TIMEOUT
    else:
        proxies = None
        timeout = DEFAULT_TIMEOUT

    try:
        request = requests.get(url, timeout=timeout, proxies=proxies)
        request.raise_for_status()
    except Exception as e:
        message = 'Unable to reach {}: {}'.format(url, e)
        logging.critical(message)
        return False
    logging.info('Probing {} successful.'.format(url))
    return True


if __name__ == '__main__':
    probe_online = probe(sys.argv[1])
    if probe_online is True:
        exit(0)
    else:
        exit(1)
