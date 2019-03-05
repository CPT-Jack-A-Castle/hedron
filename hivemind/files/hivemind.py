#!/usr/bin/python3

import json
import time
import os
import logging
from socket import gethostname

import aaargh
from sh import uptime, journalctl, systemctl

import notbit

logging.basicConfig(level=logging.INFO)

cli = aaargh.App()


def get_config():
    """
    Returns and validates the config.
    """
    valid_options = ('bitmessage_address',)
    with open('/etc/hivemind.json') as hivemind_config_file:
        hivemind_config = json.load(hivemind_config_file)

    for entry in hivemind_config:
        if entry not in valid_options:
            raise ValueError('{} invalid option.'.format(entry))

    for entry in valid_options:
        if entry not in hivemind_config:
            raise ValueError('{} missing option.'.format(entry))

    return hivemind_config


@cli.cmd
def beacon(bitmessage_address=None):
    """
    Sends out a beacon to let everyone know it's still alive.
    """
    if bitmessage_address is None:
        bitmessage_address = get_config()['bitmessage_address']
    notbit.send_message(bitmessage_address,
                        beacon_message(),
                        'Hivemind Beacon for {}'.format(gethostname()))
    return True


@cli.cmd
def uptime_reset(bitmessage_address=None):
    """
    Sends out a beacon to let everyone know about a uptime reset.
    """
    if bitmessage_address is None:
        bitmessage_address = get_config()['bitmessage_address']
    notbit.send_message(bitmessage_address,
                        beacon_message(),
                        'Uptime reset on {}'.format(gethostname()))
    return True


@cli.cmd
def hello_world(bitmessage_address=None):
    """
    Sends out a beacon to let everyone know we were born.
    """
    if bitmessage_address is None:
        bitmessage_address = get_config()['bitmessage_address']
    notbit.send_message(bitmessage_address,
                        beacon_message(),
                        'Hello world from {}'.format(gethostname()))
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
def send_alert_if_necessary(bitmessage_address=None):
    """
    Fire off an alert if we need to.
    """
    if bitmessage_address is None:
        bitmessage_address = get_config()['bitmessage_address']

    alerts = grab_alert_if_alertable()
    if alerts is not None:
        message = beacon_message()
        message += '\n\nLogs truncated to first 4096 bytes\n'
        message += alerts
        logging.info('Sending alert')
        notbit.send_message(bitmessage_address,
                            message,
                            'ALERTS for {}'.format(gethostname()))
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
