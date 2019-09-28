import pytest
from mock import patch

import vmmanagement_topup


@patch('time.sleep')
@patch('hedron.virtual_machine_info')
@patch('vmmanagement_topup.topup_vm')
def test_topup_vm_and_wait(mock_topup_vm,
                           mock_virtual_machine_info,
                           mock_sleep):
    # Fairly incomplete, but tests the basics.
    mock_topup_vm.return_value = True
    vm_info = {'expiration': 1000}
    mock_virtual_machine_info.return_value = vm_info
    assert vmmanagement_topup.topup_vm_and_wait({'machine_id': 'justamachine',
                                                 'expiration': 1000}) is True
    # Instant sleep
    vm_info['expiration'] = 900
    assert vmmanagement_topup.topup_vm_and_wait({'machine_id': 'justamachine',
                                                 'expiration': 900}) is True
    mock_sleep.return_value.return_value = True
    with pytest.raises(ValueError):
        vmmanagement_topup.topup_vm_and_wait({'machine_id': 'justamachine',
                                              'expiration': 901})

# This is minimal. We should test payments at least, like we do with
# vmmanagement_create.
