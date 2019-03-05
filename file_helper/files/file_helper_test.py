import file_helper

import pytest


def test_validate_input():
    assert file_helper.validate_input('bob', exactly_bytes=3) is True
    assert file_helper.validate_input('bob', atmost_bytes=3) is True
    assert file_helper.validate_input('bob', atleast_bytes=3) is True

    assert file_helper.validate_input('bob', atmost_bytes=4) is True
    assert file_helper.validate_input('bob', atleast_bytes=2) is True

    with pytest.raises(ValueError):
        file_helper.validate_input('bob', exactly_bytes=4)

    with pytest.raises(ValueError):
        file_helper.validate_input('bob', atleast_bytes=4)

    with pytest.raises(ValueError):
        file_helper.validate_input('bob', atmost_bytes=2)
