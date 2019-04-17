#!/usr/bin/python3

import json
import logging
import sys

import aaargh
from sporestackv2.ssh import ssh
from sporestackv2 import validate

API_VERSION = 2

cli = aaargh.App()


def normalize_argument(argument):
    """
    Helps normalize arguments from aaargh that may not be what we want.
    """
    if argument == 'False':
        return False
    else:
        return argument


# FIXME: ordering
@cli.cmd
@cli.cmd_arg('hostname')
@cli.cmd_arg('machine_id')
@cli.cmd_arg('--hostaccess', type=bool, default=False)
@cli.cmd_arg('--override_code', type=str, default=None)
@cli.cmd_arg('--organization', type=str, default=None)
@cli.cmd_arg('--managed', type=bool, default=False)
@cli.cmd_arg('--currency', type=str, default=None)
@cli.cmd_arg('--cores', type=int, default=1)
@cli.cmd_arg('--memory', type=int)
@cli.cmd_arg('--disk', type=int)
@cli.cmd_arg('--days', type=int)
@cli.cmd_arg('--bandwidth', type=int)
@cli.cmd_arg('--ipv4')
@cli.cmd_arg('--ipv6')
@cli.cmd_arg('--settlement_token', type=str, default=None)
@cli.cmd_arg('--refund_address', type=str, default=None)
@cli.cmd_arg('--qemuopts', type=str, default=None)
def create(hostname,
           machine_id,
           days,
           disk,
           memory,
           ipv4,
           ipv6,
           bandwidth,
           organization=None,
           refund_address=None,
           cores=1,
           currency='bch',
           managed=False,
           override_code=None,
           settlement_token=None,
           qemuopts=None,
           hostaccess=False):
    ipv4 = normalize_argument(ipv4)
    ipv6 = normalize_argument(ipv6)
    bandwidth = normalize_argument(bandwidth)
    validate.ipv4(ipv4)
    validate.ipv6(ipv6)
    validate.bandwidth(bandwidth)
    create_dict = {'api_version': API_VERSION,
                   'machine_id': machine_id,
                   'days': days,
                   'disk': disk,
                   'memory': memory,
                   'refund_address': refund_address,
                   'cores': cores,
                   'managed': managed,
                   'currency': currency,
                   'organization': organization,
                   'bandwidth': bandwidth,
                   'ipv4': ipv4,
                   'ipv6': ipv6,
                   'override_code': override_code,
                   'settlement_token': settlement_token,
                   'qemuopts': qemuopts,
                   'hostaccess': hostaccess}
    json_arguments = json.dumps(create_dict)
    stdout, stderr, return_code = ssh(hostname, 'create', json_arguments)
    if return_code != 0:
        message = 'Creation failure: stdout: {} stderr: {}'.format(stdout,
                                                                   stderr)
        raise ValueError(message)
    output_json = stdout.decode('utf-8')
    returned_dict = json.loads(output_json)
    if returned_dict['latest_api_version'] > API_VERSION:
        logging.warning('New API version may be available.')

    return returned_dict


@cli.cmd
@cli.cmd_arg('hostname')
@cli.cmd_arg('machine_id')
@cli.cmd_arg('--settlement_token', type=str, default=None)
@cli.cmd_arg('--override_code', type=str, default=None)
@cli.cmd_arg('--currency', type=str, default=None)
@cli.cmd_arg('--days', type=int)
@cli.cmd_arg('--refund_address', type=str, default=None)
def topup(hostname,
          machine_id,
          days,
          currency,
          settlement_token=None,
          refund_address=None,
          override_code=None):
    topup_dict = {'api_version': API_VERSION,
                  'machine_id': machine_id,
                  'days': days,
                  'refund_address': refund_address,
                  'settlement_token': settlement_token,
                  'currency': currency,
                  'override_code': override_code}
    json_arguments = json.dumps(topup_dict)
    command = 'topup {}'.format(machine_id)
    stdout, stderr, return_code = ssh(hostname, command, json_arguments)
    if return_code != 0:
        message = 'Topup failure: stdout: {} stderr: {}'.format(stdout,
                                                                stderr)
        raise ValueError(message)
    output_json = stdout.decode('utf-8')
    returned_dict = json.loads(output_json)
    if returned_dict['latest_api_version'] > API_VERSION:
        logging.warning('New API version may be available.')
    return returned_dict


@cli.cmd
@cli.cmd_arg('hostname')
@cli.cmd_arg('machine_id')
def exists(hostname, machine_id):
    """
    Checks if the VM exists.
    """
    command = 'exists {}'.format(machine_id)
    stdout, stderr, return_code = ssh(hostname, command)
    if return_code == 0:
        return True
    elif return_code == 1:
        return False
    else:
        raise ValueError('Unexpected return code of {}: {}'.format(stderr))


@cli.cmd
@cli.cmd_arg('hostname')
@cli.cmd_arg('machine_id')
def status(hostname, machine_id):
    """
    Checks if the VM is started or stopped.
    """
    command = 'status {}'.format(machine_id)
    stdout, stderr, return_code = ssh(hostname, command)
    if return_code == 0:
        return True
    elif return_code == 1:
        return False
    else:
        raise ValueError('Unexpected return code of {}: {}'.format(stderr))


@cli.cmd
@cli.cmd_arg('hostname')
@cli.cmd_arg('machine_id')
def start(hostname, machine_id):
    """
    Boots the VM.
    """
    command = 'start {}'.format(machine_id)
    stdout, stderr, return_code = ssh(hostname, command)
    if return_code != 0:
        raise ValueError('start failed: {}'.format(stderr))
    return True


@cli.cmd
@cli.cmd_arg('hostname')
@cli.cmd_arg('machine_id')
def stop(hostname, machine_id):
    """
    Immediately kills the VM.
    """
    command = 'stop {}'.format(machine_id)
    stdout, stderr, return_code = ssh(hostname, command)
    if return_code != 0:
        raise ValueError('stop failed: {}'.format(stderr))
    return True


@cli.cmd
@cli.cmd_arg('hostname')
@cli.cmd_arg('machine_id')
def info(hostname, machine_id):
    """
    Returns info about the VM.
    """
    command = 'info {}'.format(machine_id)
    stdout, stderr, return_code = ssh(hostname, command)
    if return_code != 0:
        raise ValueError('info failed: {}'.format(stderr))
    return json.loads(stdout.decode('utf-8'))


@cli.cmd
@cli.cmd_arg('hostname')
@cli.cmd_arg('machine_id')
def ipxescript(hostname, machine_id, ipxescript=None):
    """
    Trying to make this both useful as a CLI tool and
    as a library. Not really sure how to do that best.
    """
    if ipxescript is None:
        if __name__ == '__main__':
            ipxescript = sys.stdin.read()
        else:
            raise ValueError('ipxescript must be set.')
    command = 'ipxescript {}'.format(machine_id)
    stdout, stderr, return_code = ssh(hostname, command, stdin=ipxescript)
    if return_code != 0:
        raise ValueError('ipxescript failed to update: {}'.format(stderr))
    return True


@cli.cmd
@cli.cmd_arg('hostname')
@cli.cmd_arg('machine_id')
@cli.cmd_arg('bootorder')
def bootorder(hostname, machine_id, bootorder):
    command = 'bootorder {}'.format(machine_id)
    stdout, stderr, return_code = ssh(hostname, command, bootorder)
    if return_code != 0:
        raise ValueError('bootorder failed to update: {}'.format(stderr))
    return True


@cli.cmd
@cli.cmd_arg('hostname')
def help(hostname):
    stdout, stderr, return_code = ssh(hostname, 'help')
    if return_code != 0:
        raise ValueError('help did not return 0.')
    return stdout


@cli.cmd
@cli.cmd_arg('hostname')
def host_info(hostname):
    """
    Returns info about the host.

    FIXME: Returns json for now, should return a dict?
    """
    command = 'host_info'
    stdout, stderr, return_code = ssh(hostname, command)
    if return_code != 0:
        raise ValueError('host_info failed: {}'.format(stderr))
    return json.loads(stdout.decode('utf-8'))


@cli.cmd
@cli.cmd_arg('hostname')
@cli.cmd_arg('machine_id')
def serialconsole(hostname, machine_id):
    """
    ctrl + backslash to quit.
    """
    command = 'serialconsole {}'.format(machine_id)
    ssh(hostname, command, interactive=True)
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
