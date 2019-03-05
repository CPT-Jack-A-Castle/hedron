#!/usr/bin/env python3

# Consider increasing check digits in the future.

import sys
from hashlib import sha256
from base64 import b64encode, urlsafe_b64encode

import aaargh
import argon2
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC as pbkdf2hmac
from cryptography.hazmat.backends import default_backend

from pgpwordify import pgpwordify

cli = aaargh.App()


@cli.cmd
@cli.cmd_arg('passphrase')
def passphrase_to_hash(passphrase):
    """
    Returns a much more complex hash based on the passphrase. This is what
    all passwords and subsequent hashes should be derived from. It's
    computationally intense and makes cracking on the blockchain, bitmessage,
    etc, significantly more difficult.
    """
    secret = bytes(passphrase, 'utf-8')
    salt = bytes('superduperlonggenericsalt', 'utf-8')
    # Once these values are set, do not mess with them! You'll break all
    # existing brainvaults.
    hash = argon2.low_level.hash_secret_raw(secret=secret,
                                            salt=salt,
                                            time_cost=50,
                                            parallelism=4,
                                            memory_cost=20480,
                                            hash_len=32,
                                            type=argon2.low_level.Type.ID)
    return hash.hex()


def is_hash(hash):
    if len(hash) == 64:
        for character in hash:
            if character not in 'abcdef01234567890':
                raise ValueError('Cannot have 64 character passphrase.')
        return True
    else:
        return False


def normalize_passphrase(passphrase):
    """
    Takes a passphrase or hash and normalizes it to a hash.
    """
    if len(passphrase) == 0:
        raise ValueError('Passphrase length must not be zero.')
    if is_hash(passphrase):
        hash = passphrase
    else:
        hash = passphrase_to_hash(passphrase)
    return hash


@cli.cmd
@cli.cmd_arg('passphrase')
def public(passphrase):
    """
    Generates a "public" username for use in email addresses, etc.

    This is extremely arbitrary. If you mess with it you'll break old ones.

    It's also very purposed. Let's say you want an email address. We could
    do three PGP list words and it starts to sound like garbage. Then you
    need separators, which makes it look "funny" to outsiders.

    We could do two PGP list words, then we only have 16k possibilities.
    Or we could do two PGP list words, no separator, and have two digits on
    the end. It's supposed to not be super "weird" to the layman, but not
    have very high risk of collisions.
    """
    # Not sure if it's necessary to use the hash for this, but shouldn't
    # hurt. Does expose less data about the original passphrase.
    passphrase_hash = normalize_passphrase(passphrase)
    phrase_to_hash = '{}.. public'.format(passphrase_hash)
    hashed_passphrase = sha256(phrase_to_hash.encode('utf-8')).digest()
    pgpword = pgpwordify(hashed_passphrase[0:2], separator='')
    # Add a digit.
    pgpword += str(hashed_passphrase[6] % 10)
    # More more digit...
    pgpword += str(hashed_passphrase[7] % 10)
    return pgpword


@cli.cmd
@cli.cmd_arg('passphrase')
@cli.cmd_arg('service')
def password_hash(passphrase, service, hex_output=True):
    """
    Returns a full length hash password. Not very palatable, but more secure.
    """
    if not isinstance(service, str):
        raise TypeError('service must be a string.')
    if len(service) == 0:
        raise ValueError('service must have a non-zero length.')
    passphrase_hash = normalize_passphrase(passphrase)
    # If you mess with this, you break existing passwords.
    to_hash = '{} password for {}'.format(passphrase_hash, service)
    to_hash = to_hash.encode('utf-8')
    hashed_password = sha256(to_hash)
    if hex_output is True:
        hashed_password = hashed_password.hexdigest()
    else:
        hashed_password = hashed_password.digest()
    return hashed_password


@cli.cmd
@cli.cmd_arg('passphrase')
@cli.cmd_arg('service')
def password(passphrase, service):
    """
    Returns a more "palatable" password than password_hash.
    For example, you'd use this for a web login password and
    password_hash for your Bitcoin wallet.

    Todo: This should be extensible with local json files,
    including the option to manually set a password.
    """
    # We could use the hex output but I *think* these passwords would be half
    # as complex. Not positive, but that seems about right.
    hashed_password = password_hash(passphrase, service, hex_output=False)
    # Guarantee that there's always a lower, upper, and a number to satisfy
    # most password requirements.
    password = 'aA1'
    # Map the hash to lower case, upper case, and numbers.
    password += b64encode(hashed_password).decode('utf-8')
    # Strip out the base64 /, +, = components.
    password = password.replace('/', '').replace('+', '').replace('=', '')
    # Shorten to 16 characters.
    return password[:16]


def derive_key(passphrase_hash):
    """
    Returns a PBKDF2 key from a passphrase hash. For use with Fernet and
    others.
    """
    pbkdf2 = pbkdf2hmac(algorithm=hashes.SHA256(),
                        length=32,
                        salt=b'So many keys in my brain. Where are the locks?',
                        iterations=10000,
                        backend=default_backend())
    raw_key = pbkdf2.derive(passphrase_hash.encode('utf-8'))
    return urlsafe_b64encode(raw_key)


@cli.cmd
@cli.cmd_arg('passphrase')
def encrypt(passphrase, data=None):
    """
    Encrypts data from stdin or the data argument with the specified
    passphrase.

    Returns the encrypted output.
    Note that the output is different every time, even with the same data
    and passphrase. Fernet uses a timestamp and a random salt in every
    encryption call.
    """
    if data is None:
        if __name__ == '__main__':
            # sys.stdin.buffer returns bytes
            data = sys.stdin.buffer.read()
        else:
            raise ValueError('data must be set.')
    passphrase_hash = normalize_passphrase(passphrase)
    key = derive_key(passphrase_hash)
    return Fernet(key).encrypt(data)


@cli.cmd
@cli.cmd_arg('passphrase')
def decrypt(passphrase, encrypted_data=None):
    """
    Decrypts data from stdin or the encrypted_data argument with the
    specified passphrase.

    Returns the normalized output.
    """
    if encrypted_data is None:
        if __name__ == '__main__':
            # sys.stdin.buffer returns bytes
            encrypted_data = sys.stdin.buffer.read()
        else:
            raise ValueError('encrypted_data must be set.')
    passphrase_hash = normalize_passphrase(passphrase)
    key = derive_key(passphrase_hash)
    return Fernet(key).decrypt(encrypted_data)


if __name__ == '__main__':
    output = cli.run()
    if output is True:
        exit(0)
    elif output is False:
        exit(1)
    elif isinstance(output, bytes):
        sys.stdout.buffer.write(output)
    else:
        print(output)
    exit(0)
