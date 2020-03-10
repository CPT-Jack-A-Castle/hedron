# Does not directly top up the VM, only issues a request for root to do so.


import json
import os
import logging
import time

from sporestackv2 import validate

import hedron
from vmmanagement_create import (get_and_validate_config,
                                 override,
                                 cost_in_cents,
                                 days_to_expiration,
                                 existing_txids,
                                 payment)


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
                          settlement_token=None,
                          affiliate_token=None,
                          affiliate_amount=None):
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
    validate.affiliate_amount(affiliate_amount)
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
        # There is a bug with this, it uses the whole amount of bandwidth
        # over whatever timespan as the per-day calculation. So a 28 day server
        # at 32GiB per day will try to "pop up" at 28*32GiB per day and not
        # 32GiB per day.
        # bandwidth = vm_data['bandwidth']
        # Hack for now.
        bandwidth = 0
        cents = cost_in_cents(days=days,
                              cores=vm_data['cores'],
                              memory=vm_data['memory'],
                              disk=vm_data['disk'],
                              ipv4=vm_data['ipv4'],
                              ipv6=vm_data['ipv6'],
                              bandwidth=bandwidth)
        token = settlement_token
        business_token = config['settlers_business_token']
        pay = payment(machine_id,
                      currency,
                      cents,
                      address,
                      existing_txids=existing_txids(currency),
                      settlers_endpoint=config['settlers_endpoint'],
                      settlers_customer_token=token,
                      settlers_business_token=business_token,
                      monero_rpc=config['monero_rpc'],
                      affiliate_amount=affiliate_amount,
                      affiliate_token=affiliate_token)
        return_data['txid'] = pay.txid
        return_data['payment']['amount'] = pay.amount
        return_data['payment']['uri'] = pay.uri
        return_data['payment']['usd'] = pay.usd
        return_data['payment']['address'] = pay.address

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
