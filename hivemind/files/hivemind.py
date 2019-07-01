#!/usr/bin/python3

import json
import time
import os
import logging
from socket import gethostname

import aaargh
from sh import uptime, journalctl, systemctl

import notbit

CONFIG_FILE = '/etc/hivemind.json'

logging.basicConfig(level=logging.INFO)

cli = aaargh.App()


@cli.cmd
def get_config():
    """
    Returns and validates the config.
    """
    valid_options = ('methods',)
    with open(CONFIG_FILE) as hivemind_config_file:
        hivemind_config = json.load(hivemind_config_file)

    for entry in hivemind_config:
        if entry not in valid_options:
            raise ValueError('{} invalid option.'.format(entry))

    for entry in valid_options:
        if entry not in hivemind_config:
            raise ValueError('{} missing option.'.format(entry))

    valid_methods = ['bitmessage', 'local_log']
    for method in hivemind_config['methods']:
        if method not in valid_methods:
            msg = '{} is not a valid method. Try: '.format(method,
                                                           valid_methods)
            raise ValueError(msg)

    if len(hivemind_config['methods']) == 0:
        raise ValueError('Must have at least one method.')

    return hivemind_config


def relay_message(subject, message):
    methods = get_config()['methods']
    for method in methods:
        if method == 'bitmessage':
            address = methods[method]['address']
            relay_message_bitmessage(address, subject, message)
        elif method == 'local_log':
            file = methods[method]['file']
            relay_message_local_log(file, subject, message)
        else:
            raise ValueError('{} is not a valid method.'.format(method))


def relay_message_bitmessage(address, subject, message):
    logging.info("Sending bitmessage.")
    notbit.send_message(address=address, message=message, subject=subject)


def relay_message_local_log(file, subject, message):
    logging.info("Writing to local log file.")
    with open(file, mode='a') as fp:
        fp.write(subject)
        fp.write(message)
        fp.write("\n")


@cli.cmd
def beacon():
    """
    Sends out a beacon to let everyone know it's still alive.
    """
    relay_message(subject='Hivemind Beacon for {}'.format(gethostname()),
                  message=beacon_message())
    return True


@cli.cmd
def uptime_reset():
    """
    Sends out a beacon to let everyone know about a uptime reset.
    """
    relay_message(subject='Uptime reset on {}'.format(gethostname()),
                  message=beacon_message())
    return True


@cli.cmd
def hello_world():
    """
    Sends out a beacon to let everyone know we were born.
    """
    relay_message(subject='Hello world from {}'.format(gethostname()),
                  message=beacon_message())
    return True


def _get_hiddensshd_hostname():
    hostname_path = '/etc/tor/hiddensshd/hostname'
    if os.path.exists(hostname_path):
        with open(hostname_path) as hostname_fp:
            return hostname_fp.read()
    else:
        return False


def beacon_message():
    """
    Returns the message for sending as a beacon.
    """
    hostname = gethostname()
    beacon_time = time.strftime("%Y-%m-%dT%H:%M:%S", time.gmtime())
    hiddensshd_hostname = _get_hiddensshd_hostname()
    message = """Hostname: {}
Time: {}
Uptime: {}
""".format(hostname, beacon_time, uptime())
    if hiddensshd_hostname is not False:
        message += 'HiddenSSH Hostname: {}'.format(hiddensshd_hostname)
    else:
        message += 'No HiddenSSH hostname found.'
    return message


def journalctl_critical_logs(since):
    alerts = repr(journalctl('-S', since, '-p', 'crit', '--no-pager'))
    if alerts == '-- No entries --\n':
        alerts = None
    return alerts


def journalctl_all_logs(since):
    all_logs_since = repr(journalctl('-S', since, '--no-pager'))
    return all_logs_since


def systemctl_failed_units():
    """
    Returns string output of failed units list, or None if none.
    """
    command_output = repr(systemctl('list-units', '--state=failed'))
    if '0 loaded units listed' in command_output:
        return None
    else:
        return command_output


def grab_alert_if_alertable():
    """
    Returns text of alert or None.
    """
    # We run this every ten minutes and pull logs from fifteen minutes ago.
    # This is to help avoid an unlikely case where we don't run right when
    # we expect we will.
    since = time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime(time.time() - 900))

    alerts = ""

    # Look for failed services.
    failed_units = systemctl_failed_units()
    if failed_units is not None:
        alerts += failed_units

    # Grab only "critical" priority alerts.
    critical_logs = journalctl_critical_logs(since)
    if critical_logs is not None:
        alerts += critical_logs

    # Now grab them all and process.
    all_logs_since = journalctl_all_logs(since)
    for line in all_logs_since.splitlines():
        if 'CRITICAL' in line or 'Traceback' in line:
            alerts += line.strip('\n')
            break

    if alerts == "":
        alerts = None
    return alerts


@cli.cmd
def send_alert_if_necessary():
    """
    Fire off an alert if we need to.
    """

    alerts = grab_alert_if_alertable()
    if alerts is not None:
        message = beacon_message()
        message += '\n\nLogs truncated to first 4096 bytes\n'
        message += alerts
        logging.info('Sending alert')
        relay_message(subject='ALERTS for {}'.format(gethostname()),
                      message=message)
    return True


if __name__ == '__main__':
    output = cli.run()
    if output is True:
        exit(0)
    elif output is False:
        exit(1)
    else:
        print(output)
        exit(0)
