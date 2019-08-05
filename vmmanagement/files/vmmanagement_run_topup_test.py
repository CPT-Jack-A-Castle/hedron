import pytest

import vmmanagement_run_topup

valid_id = '01ba4719c80b6fe911b091a7c05124b64eeece964e09c058ef8f9805daca546b'

valid_options = {'machine_id': valid_id,
                 'currency': None,
                 'txid': ['txid'],
                 'expiration': 1000}


def test_validate_options():
    assert vmmanagement_run_topup.validate_options(valid_options) is True
    invalid_options = valid_options.copy()
    invalid_options['what_is_this'] = None
    with pytest.raises(ValueError):
        vmmanagement_run_topup.validate_options(invalid_options)
