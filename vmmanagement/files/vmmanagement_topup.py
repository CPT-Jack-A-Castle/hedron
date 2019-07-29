# Does not directly top up the VM, only issues a request for root to do so.


import sys
import json
import os
import logging
import time

from systemd.journal import JournalHandler
from sporestackv2 import validate, utilities

import hedron
from vmmanagement_create import (get_and_validate_config,
                                 override,
                                 cost_in_cents,
                                 days_to_expiration,
                                 existing_txids,
                                 payment)

# Log to systemd.
logging.root.handlers.clear()
logging.root.addHandler(JournalHandler())
logging.root.setLevel(logging.INFO)


def _exception_handler(exception_type, exception_message, traceback):
    """
    Exception handler

    ValueErrors and TypeErrors we send back details on.
    If it's not one of those, something broke on our end and we need to fix
    it.

    Remember, this gets ran over SSH through vmmanagement_shell.

    FIXME: Not sure how to handle traceback, it's an object and not a string.
    """
    exception_type = exception_type.__name__
    if exception_type in ['ValueError', 'TypeError']:
        print(exception_message, file=sys.stderr)
    else:
        print('Something broke. Please contact us for help.', file=sys.stderr)
        logging.critical('{}: {}'.format(exception_type, exception_message))


sys.excepthook = _exception_handler


def topup_vm(topup_data):
    """
    All security checks passed, payment processed.
    Time to tell the host to launch the VM.
    """
    directory = '/var/tmp/vmmanagement_topup'
    machine_id = topup_data['machine_id']
    json_path = os.path.join(directory, '{}.json'.format(machine_id))
    with open(json_path, 'x') as json_file:
        json.dump(topup_data, json_file)
    return True


def topup_vm_and_wait(topup_data):
    topup_vm(topup_data)
    machine_id = topup_data['machine_id']
    expiration = topup_data['expiration']
    # Up to 30 seconds for expiration to be updated.
    for tries in range(1, 30 + 1):
        data = hedron.virtual_machine_info(machine_id)
        if data['expiration'] == expiration:
            return True
        else:
            time.sleep(1)
    logging.critical('VM topup failed for {}'.format(machine_id))
    raise ValueError('Fatal error, VM topup failed.')


def virtual_machine_topup(machine_id,
                          days,
                          currency,
                          refund_address=None,
                          override_code=None,
                          settlement_token=None):
    config = get_and_validate_config()
    # We should have a draining for topups separately.
    # if config['draining'] is True:
    #     raise ValueError('Host is draining, unavailable for topups')
    if config['topup_enabled'] is False:
        raise ValueError('Host does not allow topups')

    return_data = {'latest_api_version': 2,
                   'payment': {'address': None, 'amount': 0},
                   'refund_tx': None,
                   'created': False,
                   'paid': False,
                   'warning': None,
                   'expiration': 1,
                   'txid': None}
    validate.machine_id(machine_id)
    validate.refund_address(refund_address)
    validate.currency(currency)
    # settlement_token is validated in settlers.

    logging.info('topup request for {}'.format(machine_id))

    vm_data = hedron.virtual_machine_info(machine_id)
    if not override(override_code):
        if currency not in config['currencies']:
            msg = 'currency must be one of: {}'.format(config['currencies'])
            raise ValueError(msg)
    else:
        return_data['paid'] = True

    validate.days(days)

    if return_data['paid'] is False:
        address = config['currencies'][currency]
        if currency != 'settlement':
            return_data['payment']['address'] = address
        cents = cost_in_cents(days=days,
                              cores=vm_data['cores'],
                              memory=vm_data['memory'],
                              disk=vm_data['disk'],
                              ipv4=vm_data['ipv4'],
                              ipv6=vm_data['ipv6'],
                              bandwidth=vm_data['bandwidth'],
                              currency=currency)
        logging.info('Cost in cents: {}'.format(cents))
        token = settlement_token
        txid, amount = payment(machine_id,
                               currency,
                               cents,
                               address,
                               existing_txids=existing_txids(currency),
                               settlers_endpoint=config['settlers_endpoint'],
                               settlers_customer_token=token)
        return_data['txid'] = txid
        return_data['payment']['amount'] = amount
        uri = utilities.payment_to_uri(address=address,
                                       currency=currency,
                                       amount=amount)
        return_data['payment']['uri'] = uri
        return_data['payment']['usd'] = utilities.cents_to_usd(cents)

        if return_data['txid'] is not None:
            return_data['paid'] = True

    expiration = days_to_expiration(days=days,
                                    current_expiration=vm_data['expiration'])
    topup_data = {'machine_id': machine_id,
                  'expiration': expiration,
                  'currency': currency,
                  'txid': return_data['txid']}
    return_data['expiration'] = expiration
    if return_data['paid'] is True:
        topup_vm_and_wait(topup_data)
        return_data['toppedup'] = True

    # toppedup and paid should always be the same, True or False.
    return return_data
