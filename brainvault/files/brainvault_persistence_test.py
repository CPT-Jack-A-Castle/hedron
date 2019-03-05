from brainvault_persistence import (mega_account_exists)


# FIXME: We need some way as qualifying some tests as requiring network and
# others that do not. We should be able to reliably develop and test offline,
# and not be held up with tests that fail because of lack of network
# connectivity. Warned maybe when we disable them, though.

# FIXME: Add account that does exist.

def test_mega_account_exists():
    assert mega_account_exists('accountdoesnotexist2',
                               'domain.notld') is False
