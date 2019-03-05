from nose.tools import raises
from mock import patch

from vmmanagement_run_create import (validate_options,
                                     random_mac,
                                     _ipv6_postfix,
                                     mac_to_ipv6,
                                     dhcpd_config,
                                     dhcpd_update_needed)
from vmmanagement_create_test import generic_valid_config

valid_id = '01ba4719c80b6fe911b091a7c05124b64eeece964e09c058ef8f9805daca546b'

valid_options = {'machine_id': valid_id,
                 'memory': 1,
                 'disk': 10,
                 'cores': 1,
                 'qemuopts': None,
                 'hostaccess': False,
                 'managed': False,
                 'ipv4': False,
                 'ipv6': False,
                 'bandwidth': -1,
                 'organization': None,
                 'currency': None,
                 'txid': None,
                 'expiration': 1000}


def test_validate_options():
    assert validate_options(valid_options) is True


invalid_options = valid_options.copy()
invalid_options['memory'] = 0.5


@raises(TypeError)
def test_validate_options_bad_memory():
    validate_options(invalid_options)


def test_random_mac():
    mac = random_mac()
    assert mac.startswith('00:') is True
    assert len(mac) == 17
    assert random_mac() != random_mac()
    for character in mac:
        if character not in '0123456789abcdef:':
            raise ValueError('Invalid character in mac')


def test_ipv6_postfix():
    mac = '00:c8:4f:9a:e2:39'
    postfix = _ipv6_postfix(mac)
    print(postfix)
    assert postfix == '02c8:4fff:fe9a:e239'


@patch('vmmanagement_create.get_config')
def test_mac_to_ip6(mock_get_config):
    mock_get_config.return_value = generic_valid_config
    mac = '00:c8:4f:9a:e2:39'
    assert mac_to_ipv6(mac) == '2001:0db8:1234:5678:02c8:4fff:fe9a:e239'


dhcpd_sample_config = """head
host ca978112ca { hardware ethernet de:ad:be:ef; fixed-address 1.2.3.4; }"""


@patch('vmmanagement_run_create.dhcpd_head')
@patch('hedron.virtual_machine_info')
@patch('hedron.list_virtual_machines')
def test_dhcpd_config(mock_list_virtual_machines,
                      mock_virtual_machine_info,
                      mock_dhcpd_head):
    mock_dhcpd_head.return_value = 'head'
    mock_list_virtual_machines.return_value = ['a']
    vm_info = {'network_interfaces': [{'ipv4': '1.2.3.4',
                                       'mac': 'de:ad:be:ef'}]}
    mock_virtual_machine_info.return_value = vm_info
    assert dhcpd_config() == dhcpd_sample_config


@patch('vmmanagement_run_create.get_dhcpd_config')
@patch('vmmanagement_run_create.dhcpd_head')
@patch('hedron.virtual_machine_info')
@patch('hedron.list_virtual_machines')
def test_dhcpd_update_needed(mock_list_virtual_machines,
                             mock_virtual_machine_info,
                             mock_dhcpd_head,
                             mock_get_dhcpd_config):
    mock_get_dhcpd_config.return_value = dhcpd_sample_config
    mock_dhcpd_head.return_value = 'head'
    mock_list_virtual_machines.return_value = ['a']
    vm_info = {'network_interfaces': [{'ipv4': '1.2.3.4',
                                       'mac': 'de:ad:be:ef'}]}
    mock_virtual_machine_info.return_value = vm_info
    assert dhcpd_update_needed() is False

    vm_info = {'network_interfaces': [{'ipv4': '2.3.4.5',
                                       'mac': 'de:ad:be:ef'}]}
    mock_virtual_machine_info.return_value = vm_info
    assert dhcpd_update_needed() is True
