from mock import patch

import autosweeper


@patch('autosweeper.get_key')
def test_can_sweep(mock_get_key):
    mock_get_key.return_value = 'shouldalwaysbezero'
    assert autosweeper.can_sweep('btc') is False
    assert autosweeper.can_sweep('bch') is False
