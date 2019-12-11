"""
Settlers of Cryptotan

Settlement layer.

All customer tokens should be unique and kept secure.
Same with business tokens.
"""

import logging
from hashlib import sha256

import requests

logging.basicConfig(level=logging.INFO)


def validate_token(token):
    """
    Validates the token.
    Must be a 64 byte lowercase hex string.
    A sha256sum, in effect.
    """
    if not isinstance(token, str):
        raise TypeError('token must be a string.')
    if len(token) != 64:
        raise ValueError('token must be exactly 64 bytes/characters.')
    for letter in token:
        if letter not in '0123456789abcdef':
            raise ValueError('token must be only 0-9, a-f (lowercase)')
    return True


def validate_amount(amount):
    """
    Validates amount.
    Must be integer and greater than 0.
    """
    if not isinstance(amount, int):
        raise TypeError('amount must be integer.')
    if amount <= 0:
        raise ValueError('amount must be 1 or greater.')
    return True


def combine_token(customer_token, business_token):
    """
    Validates, then returns hash of customer token and business token.
    """
    validate_token(customer_token)
    validate_token(business_token)
    to_hash = '{} for {}'.format(customer_token,
                                 business_token).encode('utf-8')
    combined_token = sha256(to_hash).hexdigest()
    return combined_token


def deposit_token(customer_token):
    """
    Derives the deposit token from the customer token.
    """
    validate_token(customer_token)
    to_hash = '{} deposit'.format(customer_token).encode('utf-8')
    token = sha256(to_hash).hexdigest()
    return token


def enable(admin_token,
           customer_token,
           business_token,
           endpoint):
    """
    Enable a token
    """
    combined_token = combine_token(customer_token, business_token)
    combined_deposit_token = combine_token(deposit_token(customer_token),
                                           business_token)
    url = '{}/enable'.format(endpoint)
    request_dict = {'admin_token': admin_token,
                    'combined_token': combined_token,
                    'combined_deposit_only_token': combined_deposit_token}
    request = requests.post(url, json=request_dict)
    try:
        request.raise_for_status()
    except Exception:
        raise ValueError(request.content)
    return True


def balance(customer_token,
            business_token,
            endpoint=None):
    """
    Returns balance as integer.
    """
    combined_token = combine_token(customer_token, business_token)
    url = '{}/balance/{}'.format(endpoint,
                                 combined_token)
    request = requests.get(url)
    try:
        request.raise_for_status()
    except Exception:
        raise ValueError(request.content)
    return request.json()['amount']


def add(amount,
        customer_token,
        business_token,
        endpoint):
    """
    Adds to balance.
    """
    validate_amount(amount)
    combined_token = combine_token(customer_token, business_token)
    url = '{}/add'.format(endpoint)
    request_dict = {'amount': amount, 'combined_token': combined_token}
    request = requests.post(url, json=request_dict)
    try:
        request.raise_for_status()
    except Exception:
        raise ValueError(request.content)
    return True


def subtract(amount,
             customer_token,
             business_token,
             endpoint):
    """
    Subtracts from the balance.

    Raises an exception if operation would make balance less than zero.
    """
    combined_token = combine_token(customer_token, business_token)
    validate_amount(amount)
    url = '{}/subtract'.format(endpoint)
    request_dict = {'amount': amount, 'combined_token': combined_token}
    request = requests.post(url, json=request_dict)
    try:
        request.raise_for_status()
    except Exception:
        raise ValueError(request.content)
    return True


def deposit(amount,
            deposit_token,
            business_token,
            endpoint):
    """
    Deposits to regular token's balance via the deposit only token.
    """
    validate_amount(amount)
    combined_token = combine_token(deposit_token, business_token)
    url = '{}/deposit'.format(endpoint)
    request_dict = {'amount': amount,
                    'combined_deposit_only_token': combined_token}
    request = requests.post(url, json=request_dict)
    try:
        request.raise_for_status()
    except Exception:
        raise ValueError(request.content)
    return True


def deposit_only_token_enabled(deposit_token,
                               business_token,
                               endpoint=None):
    """
    Returns True if enabled.
    """
    combined_token = combine_token(deposit_token, business_token)
    url = '{}/depositOnlyTokenEnabled/{}'.format(endpoint, combined_token)
    request = requests.get(url)
    try:
        request.raise_for_status()
    except Exception:
        raise ValueError(request.content)
    return True
