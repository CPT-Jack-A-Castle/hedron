from mock import patch

from runqemu_py import (virtual_machine_exists,
                        list_expired_virtual_machines)


def test_virtual_machine_exists():
    assert virtual_machine_exists('404_vm_not_found') is False


@patch('time.time')
@patch('hedron.virtual_machine_info')
@patch('hedron.list_virtual_machines')
def test_list_expired_virtual_machines(mock_list_virtual_machines,
                                       mock_virtual_machine_info,
                                       mock_time):
    mock_time.return_value = 10.0
    mock_list_virtual_machines.return_value = ['a', 'b', 'c']
    mock_virtual_machine_info.return_value = {'expiration': 0}
    assert list_expired_virtual_machines() == []
    mock_virtual_machine_info.return_value = {'expiration': 11}
    assert list_expired_virtual_machines() == []
    mock_virtual_machine_info.return_value = {'expiration': 9}
    assert list_expired_virtual_machines() == ['a', 'b', 'c']
    mock_list_virtual_machines.return_value = []
    assert list_expired_virtual_machines() == []
