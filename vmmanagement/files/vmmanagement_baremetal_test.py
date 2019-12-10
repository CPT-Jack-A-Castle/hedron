import logging

import pytest
from mock import patch

import vmmanagement_baremetal
from vmmanagement_create_test import generic_valid_config


@patch('ipxeplease.operating_systems')
@patch('vmmanagement_create.get_config')
@patch('vmmanagement_create.get_available_resources')
def test_host_info(mock_available_resources,
                   mock_get_config,
                   mock_operating_systems):
    operating_systems = ['debian-9', 'coreos-stable']
    mock_operating_systems.return_value = operating_systems
    mock_available_resources.return_value = {'disk': 20,
                                             'memory': 4,
                                             'cores': 4,
                                             'ipv4_addresses': 0}
    our_config = generic_valid_config.copy()
    # Lists can be unstable in Python, so not having multiple list entries
    # makes this test more stable.
    our_config['ipv4'] = ['/32']
    our_config['ipv6'] = ['/128']
    mock_get_config.return_value = our_config
    expected = {'cores': 4,
                'memory': 4,
                'disk': 20,
                'currencies': ['bch', 'btc'],
                'ipv4': ['/32'],
                'ipv4_addresses': 0,
                'ipv6': ['/128'],
                'draining': False,
                'topup_enabled': False,
                'max_cores_per_vm': 2,
                'max_disk_per_vm': 100,
                'max_memory_per_vm': 4,
                'max_days': 28,
                'operating_systems': operating_systems,
                'features': ['ipxe', 'operating_system']}
    info = vmmanagement_baremetal.host_info()
    logging.debug(info)
    assert info == expected


def test_validate_extra_ssh_and_os():
    testfunc = vmmanagement_baremetal.validate_extra_ssh_and_os
    assert testfunc(ssh_key='ssh-rsa', operating_system='debian-9') is True
    assert testfunc(ssh_key=None, operating_system=None) is True
    with pytest.raises(ValueError):
        testfunc(ssh_key=None, operating_system='debian-9')
    with pytest.raises(ValueError):
        testfunc(ssh_key='ssh-rsa', operating_system=None)
