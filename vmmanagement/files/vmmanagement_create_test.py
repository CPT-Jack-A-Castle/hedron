import pytest
from mock import patch
from nose.tools import raises

# flake8's noqa option does not let you pick specific errors.
# It just ignores the whole file.

from vmmanagement_create import (ipv4_range,
                                 days_to_expiration,
                                 virtual_machine_create,
                                 has_sufficient_resources,
                                 validate_config,
                                 get_used_resources,
                                 get_available_resources,
                                 cost_in_cents,
                                 existing_txids,
                                 payment,
                                 bandwidth_calculator)


valid_id = '01ba4719c80b6fe911b091a7c05124b64eeece964e09c058ef8f9805daca546b'

# FIXME: Got lots to add to this.

# walkingliberty for "satoshi4"
bch_address = 'bitcoincash:qzhqr2tw5kx5pj05dfxt4ly42lucug4tavdctvgrp8'
# walkingliberty for 'satoshi'
btc_address = '1xm4vFerV3pSgvBFkyzLgT1Ew3HQYrS1V'

generic_valid_config = {'currencies': {'bch': bch_address, 'btc': btc_address},
                        'ipv4': {"/32": 10, 'nat': 1, 'tor': 0},
                        'ipv6': {"/128": 1, 'nat': 1, 'tor': 0},
                        'ipv6_prefix': '2001:0db8:1234:5678',
                        'override_code': 'prettyplease',
                        'draining': False,
                        'topup_enabled': False,
                        'settlers_endpoint': None,
                        'minimum_cents_per_day': 0,
                        'max_days': 28,
                        'cents_per_disk_gb': 2,
                        'cents_per_memory_gb': 6,
                        'cents_per_core': 12,
                        'included_bandwidth_per_day_gb': 10,
                        'max_extra_bandwidth_per_day_gb': 90,
                        'cents_per_extra_bandwidth_gb': 1.5,
                        'kvmpassthrough_whole_host_only': True,
                        'max_disk_gb': 200,
                        'max_memory_gb': 10,
                        'max_cores': 4,
                        'max_cores_per_vm': 2,
                        'max_disk_per_vm': 100,
                        'max_memory_per_vm': 4,
                        'monero_rpc': None}


def test_validate_config():
    """
    This function should always return True for now.
    """
    assert validate_config(generic_valid_config) is True


def test_ipv4_range():
    start = '127.0.0.1'
    end = '127.0.0.3'
    assert ipv4_range(start, end) == [start, '127.0.0.2', end]
    assert ipv4_range('127.0.0.1', '127.0.0.2') == [start, '127.0.0.2']


@patch('time.time')
def test_days_to_expiration(mock_time):
    assert days_to_expiration(days=2) > days_to_expiration(days=1)
    arbitrary_epoch = 1523566296
    assert days_to_expiration(days=10,
                              current_expiration=arbitrary_epoch) == 1524430296
    mock_time.return_value = arbitrary_epoch
    # Add in free time, 30 minutes worth.
    assert days_to_expiration(days=10) == 1524432096


@patch('vmmanagement_create.get_config')
@patch('vmmanagement_create.get_available_resources')
def test_has_sufficient_resources(mock_available_resources, mock_get_config):
    mock_get_config.return_value = generic_valid_config
    mock_available_resources.return_value = {'disk': 20,
                                             'memory': 4,
                                             'cores': 4}
    assert has_sufficient_resources(cores=1, memory=1, disk=10) is True
    assert has_sufficient_resources(cores=1, memory=1, disk=0) is True
    assert has_sufficient_resources(cores=2, memory=2, disk=5) is True
    mock_available_resources.return_value = {'disk': 200,
                                             'memory': 4,
                                             'cores': 2}
    # More than allowed per a single VM.
    with pytest.raises(ValueError):
        has_sufficient_resources(cores=3, memory=1, disk=10)
    with pytest.raises(ValueError):
        has_sufficient_resources(cores=2, memory=5, disk=10)
    with pytest.raises(ValueError):
        has_sufficient_resources(cores=2, memory=2, disk=101)


@raises(Exception)
@patch('vmmanagement_create.get_available_resources')
def test_has_sufficient_resources_exception(mock_available_resources):
    mock_available_resources.return_value = {'disk': 20,
                                             'memory': 4,
                                             'cores': 4}
    has_sufficient_resources(cores=6, memory=2, disk=5)


@patch('hedron.virtual_machine_info')
@patch('hedron.list_virtual_machines')
def test_get_used_resources(mock_list_virtual_machines,
                            mock_virtual_machine_info):
    mock_list_virtual_machines.return_value = ['a', 'b']
    mock_virtual_machine_info.return_value = {'memory': 3,
                                              'cores': 3,
                                              'disk': 9,
                                              'ipv4': False}
    assert get_used_resources() == {'memory': 6,
                                    'cores': 6,
                                    'disk': 18,
                                    'ipv4_addresses': 0}
    mock_virtual_machine_info.return_value = {'memory': 3,
                                              'cores': 3,
                                              'disk': 9,
                                              'ipv4': '/32'}
    assert get_used_resources() == {'memory': 6,
                                    'cores': 6,
                                    'disk': 18,
                                    'ipv4_addresses': 2}


@patch('vmmanagement_create.get_config')
@patch('hedron.virtual_machine_info')
@patch('hedron.list_virtual_machines')
def test_get_available_resources(mock_list_virtual_machines,
                                 mock_virtual_machine_info,
                                 mock_get_config):
    mock_list_virtual_machines.return_value = ['a', 'b']
    mock_virtual_machine_info.return_value = {'memory': 2,
                                              'cores': 1,
                                              'disk': 9,
                                              'ipv4': False}
    mock_get_config.return_value = generic_valid_config
    assert get_available_resources() == {'memory': 6,
                                         'cores': 2,
                                         'disk': 182,
                                         'ipv4_addresses': 0}


@patch('hedron.virtual_machine_info')
@patch('hedron.list_virtual_machines')
def test_existing_txids(mock_list_virtual_machines,
                        mock_virtual_machine_info):
    mock_list_virtual_machines.return_value = ['a', 'b']
    mock_virtual_machine_info.return_value = {'txid': 'just a txid'}
    # Settlement returns an empty list to be faster.
    assert existing_txids('settlement') == []
    assert existing_txids('btc') == ['just a txid', 'just a txid']
    assert existing_txids('bch') == ['just a txid', 'just a txid']
    mock_virtual_machine_info.return_value = {'txid': ['txid 1', 'txid 2']}
    assert existing_txids('btc') == ['txid 1', 'txid 2', 'txid 1', 'txid 2']
    mock_virtual_machine_info.return_value = {}
    assert existing_txids('bsv') == []


@patch('vmmanagement_create.get_config')
def test_bandwidth_calculator(mock_get_config):
    mock_get_config.return_value = generic_valid_config
    assert bandwidth_calculator(0) == (0, 0)
    assert bandwidth_calculator(1) == (10, 0)
    assert bandwidth_calculator(5) == (10, 0)
    assert bandwidth_calculator(10) == (10, 0)
    assert bandwidth_calculator(11) == (11, 1.5)
    assert bandwidth_calculator(20) == (20, 15)
    assert bandwidth_calculator(100) == (100, 135)
    assert bandwidth_calculator(-1, override=True) == (-1, 0)
    with pytest.raises(ValueError):
        bandwidth_calculator(-1)
    valid_config = generic_valid_config.copy()
    valid_config['included_bandwidth_per_day_gb'] = -1
    mock_get_config.return_value = valid_config
    assert bandwidth_calculator(-1) == (-1, 0)
    assert bandwidth_calculator(10) == (-1, 0)
    valid_config['included_bandwidth_per_day_gb'] = 0
    assert bandwidth_calculator(5) == (5, 7.5)


def test_payment():
    """
    Checks if payment amounts are sane.
    """
    btc_pay = payment(machine_id='machine id',
                      cents=50,
                      address='1xm4vFerV3pSgvBFkyzLgT1Ew3HQYrS1V',
                      currency='btc',
                      existing_txids=[])
    # No longer doing bch payments because of Tor blocking
    # https://github.com/sporestack/bitcash/issues/42
    bsv_pay = payment(machine_id='machine id',
                      cents=50,
                      address='1xm4vFerV3pSgvBFkyzLgT1Ew3HQYrS1V',
                      currency='bsv',
                      existing_txids=[])
    assert btc_pay.txid is None
    assert bsv_pay.txid is None
    # Good test while BSV is lower than BTC (so more Satoshis)
    assert bsv_pay.amount > btc_pay.amount
    # testnet rpc test wallet
    host = "6eqrlligxznaerq52snzdzlcxujmd5pfxkodmdvtzdtayx4rfn3tgpyd.onion"
    monero_rpc = {"host": host,
                  "port": 6799,
                  "user": "demouser",
                  "password": "demopassword"}
    xmr_pay = payment(machine_id='machine id',
                      cents=50,
                      address=None,
                      currency='xmr',
                      existing_txids=[],
                      monero_rpc=monero_rpc)
    assert xmr_pay.txid is None


@raises(ValueError)
@patch('vmmanagement_create.get_config')
def test_bandwidth_calculator_too_much(mock_get_config):
    mock_get_config.return_value = generic_valid_config
    bandwidth_calculator(101)


@raises(ValueError)
@patch('vmmanagement_create.get_config')
def test_bandwidth_calculator_inf_is_bad(mock_get_config):
    mock_get_config.return_value = generic_valid_config
    bandwidth_calculator(-1)


@patch('vmmanagement_create.get_config')
def test_cost_in_cents(mock_get_config):
    our_config = generic_valid_config.copy()
    mock_get_config.return_value = our_config
    assert cost_in_cents(days=1,
                         cores=1,
                         memory=1,
                         disk=1,
                         ipv4=False,
                         ipv6=False,
                         bandwidth=0) == 20
    assert cost_in_cents(days=2,
                         cores=1,
                         memory=1,
                         disk=1,
                         ipv4=False,
                         ipv6=False,
                         bandwidth=0) == 40
    assert cost_in_cents(days=2,
                         cores=2,
                         memory=1,
                         disk=20,
                         ipv4=False,
                         ipv6=False,
                         bandwidth=0) == 140
    assert cost_in_cents(days=2,
                         cores=2,
                         memory=1,
                         disk=20,
                         ipv4='/32',
                         ipv6='/128',
                         bandwidth=10) == 162
    # minimum cents per day.
    our_config['minimum_cents_per_day'] = 50
    assert cost_in_cents(days=1,
                         cores=1,
                         memory=1,
                         disk=1,
                         ipv4=False,
                         ipv6=False,
                         bandwidth=0) == 50
    # minimum cents per day, two days.
    our_config['minimum_cents_per_day'] = 50
    assert cost_in_cents(days=2,
                         cores=1,
                         memory=1,
                         disk=1,
                         ipv4=False,
                         ipv6=False,
                         bandwidth=0) == 100


@patch('hedron.list_virtual_machines')
@patch('vmmanagement_create.get_config')
def test_virtual_machine_create_payment(mock_get_config,
                                        mock_list):
    mock_list.return_code = []
    mock_get_config.return_value = generic_valid_config
    return_data = virtual_machine_create(machine_id=valid_id,
                                         days=1,
                                         memory=1,
                                         disk=10,
                                         cores=1,
                                         currency='btc',
                                         bandwidth=0,
                                         refund_address='1address',
                                         override_code=None,
                                         qemuopts=None,
                                         managed=False,
                                         hostaccess=False)
    assert return_data['paid'] is False
    assert return_data['payment']['address'] == btc_address
    assert return_data['bandwidth'] == 0


@patch('hedron.list_virtual_machines')
@patch('vmmanagement_create.get_config')
def test_virtual_machine_create(mock_get_config,
                                mock_list_virtual_machines):
    mock_list_virtual_machines.return_code = []
    mock_get_config.return_value = generic_valid_config
    return_data = virtual_machine_create(machine_id=valid_id,
                                         days=2,
                                         memory=1,
                                         disk=10,
                                         cores=1,
                                         ipv4='/32',
                                         ipv6='/128',
                                         bandwidth=5,
                                         currency='btc',
                                         refund_address='1address',
                                         override_code=None,
                                         qemuopts=None,
                                         managed=False,
                                         hostaccess=False)
    assert return_data['paid'] is False
    # Included bandwidth is 10GiB, * 2 days.
    assert return_data['bandwidth'] == 20


# Decorator order is bottom up, not top down!
@patch('hedron.list_virtual_machines')
@patch('vmmanagement_create.launch_vm_and_wait')
@patch('vmmanagement_create.get_config')
def test_virtual_machine_create_earns_override(mock_get_config,
                                               mock_launch_vm_and_wait,
                                               mock_list_virtual_machines):
    mock_list_virtual_machines.return_code = []
    our_config = generic_valid_config.copy()
    mock_get_config.return_value = our_config
    mock_launch_vm_and_wait.return_value = {'sshhostname': 'foo.onion',
                                            'sshport': 22,
                                            'slot': 4000,
                                            'network_interfaces': [{}]}
    return_data = virtual_machine_create(machine_id=valid_id,
                                         days=2,
                                         memory=1,
                                         disk=10,
                                         cores=1,
                                         bandwidth=0,
                                         currency='bch',
                                         refund_address='1address',
                                         override_code='prettyplease',
                                         qemuopts=None,
                                         managed=False,
                                         hostaccess=False)
    assert return_data['paid'] is True
    assert return_data['created'] is True
    assert return_data['sshhostname'] == 'foo.onion'
    assert return_data['sshport'] == 22
    assert return_data['slot'] == 4000
    assert return_data['bandwidth'] == 0

    # Override should allow us to do bandwidth: -1
    return_data = virtual_machine_create(machine_id=valid_id,
                                         days=1,
                                         memory=1,
                                         disk=10,
                                         cores=1,
                                         ipv4='tor',
                                         ipv6='tor',
                                         bandwidth=-1,
                                         currency='bch',
                                         refund_address='1address',
                                         override_code='prettyplease',
                                         qemuopts=None,
                                         managed=False,
                                         hostaccess=False)
    assert return_data['paid'] is True
    assert return_data['created'] is True
    assert return_data['sshhostname'] == 'foo.onion'
    assert return_data['sshport'] == 22
    assert return_data['slot'] == 4000
    assert return_data['bandwidth'] == -1

    # Make sure draining with override does not stop new builds.
    our_config['draining'] = True
    virtual_machine_create(machine_id=valid_id,
                           days=1,
                           memory=1,
                           disk=10,
                           cores=1,
                           bandwidth=0,
                           currency='bch',
                           refund_address='1address',
                           override_code='prettyplease',
                           qemuopts=None,
                           managed=False,
                           hostaccess=False)


# Test for existing machine_id
@raises(ValueError)
@patch('hedron.list_virtual_machines')
@patch('vmmanagement_create.virtual_machine_exists')
@patch('vmmanagement_create.get_config')
def test_virtual_machine_create_already_exists(mock_get_config,
                                               mock_virtual_machine_exists,
                                               mock_list_virtual_machines):
    mock_list_virtual_machines.return_code = []
    mock_get_config.return_value = generic_valid_config
    mock_virtual_machine_exists.return_value = True
    virtual_machine_create(machine_id=valid_id,
                           days=1,
                           memory=1,
                           disk=10,
                           cores=1,
                           bandwidth=0,
                           currency='bch',
                           refund_address='1address',
                           override_code=None,
                           qemuopts=None,
                           managed=False,
                           hostaccess=False)


@raises(ValueError)
@patch('hedron.list_virtual_machines')
@patch('vmmanagement_create.get_config')
def test_virtual_machine_create_wants_hostaccess(mock_get_config,
                                                 mock_list_virtual_machines):
    mock_list_virtual_machines.return_code = []
    mock_get_config.return_value = generic_valid_config
    virtual_machine_create(machine_id=valid_id,
                           days=1,
                           memory=1,
                           disk=10,
                           cores=1,
                           bandwidth=0,
                           currency='bch',
                           refund_address='1address',
                           override_code=None,
                           qemuopts=None,
                           managed=False,
                           hostaccess=True)


@raises(ValueError)
@patch('hedron.list_virtual_machines')
@patch('vmmanagement_create.get_config')
def test_virtual_machine_create_wants_qemuopts(mock_get_config,
                                               mock_list_virtual_machines):
    mock_list_virtual_machines.return_code = []
    mock_get_config.return_value = generic_valid_config
    virtual_machine_create(machine_id=valid_id,
                           days=1,
                           memory=1,
                           disk=10,
                           cores=1,
                           bandwidth=0,
                           currency='bch',
                           refund_address='1address',
                           override_code=None,
                           qemuopts='-leet-haxor',
                           managed=False,
                           hostaccess=False)


@raises(ValueError)
@patch('hedron.list_virtual_machines')
@patch('vmmanagement_create.get_config')
def test_virtual_machine_create_wants_override(mock_get_config,
                                               mock_list_virtual_machines):
    mock_list_virtual_machines.return_code = []
    mock_get_config.return_value = generic_valid_config
    virtual_machine_create(machine_id=valid_id,
                           days=1,
                           memory=1,
                           disk=10,
                           cores=1,
                           bandwidth=0,
                           currency='bch',
                           refund_address='1address',
                           override_code='plzletmein',
                           qemuopts=None,
                           managed=False,
                           hostaccess=False)


token = 'da2876b3eb31edb4436fa4650673fc6f01f90de2f1793c4ec332b2387b09726f'
customer_token = token
token = '8eef2960bec338415417c52eec417ecbf6b218bf0dba3afb7862391c1db1e29a'
business_token = token
combined = '2cec882215c68655987b4cb4f6fc5342d7f46f36750ac6d5fcc1b5431049f344'
