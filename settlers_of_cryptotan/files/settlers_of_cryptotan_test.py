import pytest

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
