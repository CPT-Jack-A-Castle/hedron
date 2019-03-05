from mock import patch

from vmmanagement_host_info import host_info
from vmmanagement_create_test import generic_valid_config


@patch('vmmanagement_create.get_config')
@patch('vmmanagement_create.get_available_resources')
def test_host_info(mock_available_resources, mock_get_config):
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
                'currencies': ['bch'],
                'ipv4': ['/32'],
                'ipv4_addresses': 0,
                'ipv6': ['/128'],
                'draining': False,
                'topup_enabled': False,
                'max_cores_per_vm': 2,
                'max_disk_per_vm': 100,
                'max_memory_per_vm': 4,
                'max_days': 28,
                'features': ['ipxe']}
    info = host_info()
    assert info == expected
