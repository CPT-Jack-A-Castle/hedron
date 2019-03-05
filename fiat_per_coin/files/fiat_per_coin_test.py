from mock import patch

import fiat_per_coin


@patch('fiat_per_coin.time')
def test_hour_is_even(mock_time):
    mock_time.return_value = 1521381460
    assert fiat_per_coin._hour_is_even() is False
    mock_time.return_value = 1521384383
    assert fiat_per_coin._hour_is_even() is True
