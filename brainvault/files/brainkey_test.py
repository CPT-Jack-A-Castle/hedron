import pytest

from nose.tools import raises
from cryptography.fernet import InvalidToken

from brainkey import (public,
                      password,
                      password_hash,
                      derive_key,
                      encrypt,
                      decrypt,
                      passphrase_to_hash)


def test_passphrase_to_hash():
    hash1 = 'f16976f7d63ff7d9f0dcbec045afcbc3d7fe105d47391728ad9cc830354babfa'
    hash2 = 'f0820d5db399b562cb2931ed7a4739a42328ad78f849b4f6f86113010e1a88cd'
    assert passphrase_to_hash('satoshi4') == hash1
    assert passphrase_to_hash('nakamoto6') == hash2


def test_public():
    assert public('satoshi4') == 'drainagecandidate13'
    assert public('nakamoto6') == 'sweatbandcherokee67'


def test_password():
    assert password('satoshi4', 'tutanota.com') == 'aA1ro4D27929z2Fh'
    assert password('nakamoto6', 'tutanota.com') == 'aA1WFgGYm9NSZDfD'
    assert password('satoshi4', 'protonmail.ch') == 'aA1I6fA12KdqzUsq'
    assert password('nakamoto6', 'protonmail.ch') == 'aA1EM7HPgZOO87x6'
    # Empty string should raise a ValueError for either.
    with pytest.raises(ValueError):
        password('', 'protonmail.ch')
    with pytest.raises(ValueError):
        password('nakamoto6', '')


def test_password_hash():
    hash = '9e45e24105b8a7c0cf77af784e8cb1e488c461fba134778a60658669a96897bd'
    assert password_hash('satoshi4', 'test') == hash
    assert password_hash(passphrase_to_hash('satoshi4'), 'test') == hash
    # Empty string should raise a ValueError for either.
    with pytest.raises(ValueError):
        password_hash('', 'protonmail.ch')
    with pytest.raises(ValueError):
        password_hash('nakamoto6', '')


@raises(TypeError)
def test_password_bad_service_type():
    password('satoshi4', 100)


def test_derive_key():
    derived_key = b'udMPh5NPHZG3KJUfthePrNsFXpFl6dxomLYI0zEsF_g='
    assert derive_key('satoshi4') == derived_key


def test_decrypt():
    encrypted = b'gAAAAABby-hKTJAXST4nYIgy8kQVTEcuc0VW2-15YBEfvSONzZjH20jzh'\
                b'YZS9sFd8VIAEL4ij-G6SQq3TNNPyBmBJYf2RxOWdw=='
    assert decrypt('satoshi4', encrypted) == b'Nakamoto'


def test_decrypt_and_encrypt():
    """
    Test decrypt() and encrypt()

    encrypt() output is different every time, so can't test it like
    how we did decrypt()
    """
    data = b'Washington Post'
    passphrase = 'satoshi4'
    encrypted_data = encrypt(passphrase, data)
    assert decrypt(passphrase, encrypted_data) == data


@raises(InvalidToken)
def test_decrypt_wrong_pasphrase():
    encrypted = b'gAAAAABacjTCR41f4KETqkpszkgZDuj1i0SU47xVBK-XVi2km4T2yTSUQ' \
                b'mX9S4oMfwzvZyLcyd1SwrpPnyDeHAZqu1_b8eLCSQ=='
    decrypt('nakamoto6', encrypted)
