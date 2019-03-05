import pytest
import pyrqlite.dbapi2 as dbapi2
from mock import patch
from sqlite3 import Error as sqlite3_Error

import settlers_of_cryptotan as settlers

# "satoshi"
token = 'da2876b3eb31edb4436fa4650673fc6f01f90de2f1793c4ec332b2387b09726f'
# "nakamoto"
token2 = '8eef2960bec338415417c52eec417ecbf6b218bf0dba3afb7862391c1db1e29a'

customer_token = token
business_token = token2
combined = '2cec882215c68655987b4cb4f6fc5342d7f46f36750ac6d5fcc1b5431049f344'


def test_validate_token():
    assert settlers.validate_token(token) is True
    with pytest.raises(TypeError):
        settlers.validate_token(1)
    with pytest.raises(TypeError):
        settlers.validate_token(None)
    # Too short
    with pytest.raises(ValueError):
        settlers.validate_token(token[:63])
    # Too capital
    with pytest.raises(ValueError):
        settlers.validate_token(token.upper())
    # Invalid character.
    with pytest.raises(ValueError):
        settlers.validate_token(token[:63] + 'z')


def test_validate_amount():
    assert settlers.validate_amount(1) is True
    assert settlers.validate_amount(1000) is True
    with pytest.raises(TypeError):
        settlers.validate_amount(None)
    with pytest.raises(TypeError):
        settlers.validate_amount('One')
    with pytest.raises(TypeError):
        settlers.validate_amount(10.0)
    with pytest.raises(ValueError):
        settlers.validate_amount(0)
    with pytest.raises(ValueError):
        settlers.validate_amount(-1)


def test_combine_token():
    assert settlers.combine_token(customer_token, business_token) == combined


@patch('settlers_of_cryptotan._rqlite_connection')
def test_everything(mock_rqlite_connection):
    """
    Test everything in a sequence to validate that it's working.
    """
    database_connection = dbapi2.connect(host=':memory:')
    mock_rqlite_connection.return_value = database_connection

    # Not prepared yet.
    with pytest.raises(sqlite3_Error):
        settlers.balance(combined_token=combined)

    settlers.prep()
    # Not enabled yet.
    with pytest.raises(ValueError):

        settlers.balance(combined_token=combined)
    # Subtract not enabled.
    with pytest.raises(ValueError):
        settlers.subtract(1000, combined_token=combined)

    # Add not enabled.
    with pytest.raises(ValueError):
        settlers.add(1000, combined_token=combined)

    settlers.enable(combined_token=combined)
    assert settlers.balance(combined_token=combined) == 0
    settlers.add(5, combined_token=combined)
    assert settlers.balance(combined_token=combined) == 5
    settlers.subtract(5, combined_token=combined)
    assert settlers.balance(combined_token=combined) == 0
    settlers.add(1000, combined_token=combined)
    settlers.subtract(1, combined_token=combined)
    assert settlers.balance(combined_token=combined) == 999
    assert settlers.balance(customer_token=customer_token,
                            business_token=business_token) == 999

    # Balance would go negative.
    with pytest.raises(ValueError):
        settlers.subtract(1000, combined_token=combined)

    # Token never filled with money.
    with pytest.raises(ValueError):
        settlers.balance(combined_token=token)


@patch('settlers_of_cryptotan._rqlite_connection')
def test_dead_db(mock_rqlite_connection):
    # Should immediately throw connection refused.
    database_connection = dbapi2.connect(host='127.0.0.1', port=1000)
    mock_rqlite_connection.return_value = database_connection
    with pytest.raises(ConnectionRefusedError):
        settlers.balance(combined_token=combined)

    with pytest.raises(ConnectionRefusedError):
        settlers.subtract(amount=5, combined_token=combined)

    with pytest.raises(ConnectionRefusedError):
        settlers.add(amount=5, combined_token=combined)
