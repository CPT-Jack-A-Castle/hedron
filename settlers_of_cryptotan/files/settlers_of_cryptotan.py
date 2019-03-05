"""
Settlers of Cryptotan

Settlement layer.

All customer tokens should be unique and kept secure.
Same with business tokens.
"""

import logging
from hashlib import sha256

import requests
import hug
import pyrqlite.dbapi2 as dbapi2
from sqlite3 import Error as sqlite3_Error
from falcon import HTTP_400, HTTP_500

logging.basicConfig(level=logging.INFO)


def _rqlite_connection():
    return dbapi2.connect()


def _database_query(query):
    connection = _rqlite_connection()
    with connection.cursor() as cursor:
        cursor.execute(query)
        result = cursor.fetchone()
    return result, cursor.rowcount


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


def _validate_request(customer_token,
                      business_token,
                      combined_token,
                      endpoint):
    """
    Basic validation for request.

    We want to be called with only combined_token if an API, or only with
    customer_token and business_token if a client.

    And make sure we don't mix and match combined and business/customer.
    """
    if endpoint is not None:
        if customer_token is None or business_token is None:
            msg = 'customer_token and business_token must be set'
            raise ValueError(msg)
    if combined_token is not None:
        if customer_token is not None or business_token is not None:
            msg = 'Do not set customer_token or business_token with' \
                  ' combined_token'
            raise ValueError(msg)
        validate_token(combined_token)
    return True


def prep():
    query = 'CREATE TABLE balances (combined_token TEXT NOT NULL, ' \
            'balance INTEGER CHECK (balance >= 0))'
    _database_query(query)
    return True


def _enable_sql(combined_token):
    starting_balance = 0
    query = 'INSERT INTO balances (combined_token, balance) ' \
            'VALUES ("{}", {})'.format(combined_token, starting_balance)
    _database_query(query)
    return True


def enable(combined_token):
    """
    Enables a new token. Just an administrative feature for now.
    """
    validate_token(combined_token)
    _enable_sql(combined_token)
    return True


def _balance_sql(combined_token):
    query = 'SELECT balance FROM balances WHERE ' \
            'combined_token="{}"'.format(combined_token)
    output, rowcount = _database_query(query)
    if output is None:
        raise ValueError('token not enabled.')
    else:
        return output['balance']


@hug.get('/balance', versions=1)
def balance(customer_token=None,
            business_token=None,
            combined_token=None,
            endpoint=None):
    """
    Returns balance as integer.
    """
    _validate_request(customer_token, business_token, combined_token, endpoint)
    if combined_token is None:
        combined_token = combine_token(customer_token, business_token)
    if endpoint is not None:
        url = '{}/v1/balance/?combined_token={}'.format(endpoint,
                                                        combined_token)
        request = requests.get(url)
        try:
            request.raise_for_status()
        except Exception:
            raise ValueError(request.content)
        our_balance = int(request.content)
        return our_balance
    else:
        output = _balance_sql(combined_token)
        return output


def _add_sql(amount, combined_token):
    query = 'UPDATE balances SET balance = balance + {} WHERE ' \
            'combined_token="{}"'.format(amount, combined_token)
    _, rowcount = _database_query(query)
    # FIXME, standardize on error messages.
    if rowcount != 1:
        raise ValueError('token not enabled.')
    else:
        return True


@hug.post('/add', versions=1)
def add(amount,
        customer_token=None,
        business_token=None,
        combined_token=None,
        endpoint=None):
    """
    Adds to balance.
    """
    _validate_request(customer_token, business_token, combined_token, endpoint)
    validate_amount(amount)
    if combined_token is None:
        combined_token = combine_token(customer_token, business_token)
    if endpoint is not None:
        url = '{}/v1/add'.format(endpoint)
        request_dict = {'amount': amount, 'combined_token': combined_token}
        request = requests.post(url, json=request_dict)
        try:
            request.raise_for_status()
        except Exception:
            raise ValueError(request.content)
    else:
        _add_sql(amount, combined_token)
    return True


def _subtract_sql(amount, combined_token):
    query = 'UPDATE balances SET balance = balance - {} WHERE ' \
            'combined_token="{}"'.format(amount, combined_token)
    _, rowcount = _database_query(query)
    # FIXME, standardize on error messages.
    if rowcount != 1:
        raise ValueError('token not enabled.')
    else:
        return True


@hug.post('/subtract', versions=1)
def subtract(amount,
             customer_token=None,
             business_token=None,
             combined_token=None,
             endpoint=None):
    """
    Subtracts from the balance.

    Raises an exception if operation would make balance less than zero.
    """
    _validate_request(customer_token, business_token, combined_token, endpoint)
    if combined_token is None:
        combined_token = combine_token(customer_token, business_token)
    validate_amount(amount)
    if endpoint is not None:
        url = '{}/v1/subtract'.format(endpoint)
        request_dict = {'amount': amount, 'combined_token': combined_token}
        request = requests.post(url, json=request_dict)
        try:
            request.raise_for_status()
        except Exception:
            raise ValueError(request.content)
    else:
        # FIXME: Overly generic, sends this even if not prepared.
        try:
            results = _subtract_sql(amount, combined_token)
            logging.debug(results)
        except sqlite3_Error:
            raise ValueError('Insufficient balance.')
    return True


@hug.exception(TypeError)
@hug.exception(ValueError)
def hug_handle_exception(exception, response):
    response.status = HTTP_400
    logging.warning(exception)
    return str(exception)


@hug.exception(Exception)
def hug_handle_other_exceptions(exception, response):
    # 500s for these, since likely our failure and client should retry.
    response.status = HTTP_500
    logging.critical('Unhandled except in Settlers of Cryptotan')
    return str(exception)
