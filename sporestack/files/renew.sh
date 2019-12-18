#!/bin/sh

set -e

alert() {
    echo 'CRITICAL: renewal failure'
    exit 1
}

HOSTNAME=$(hostname)
DAYS=1
# This is so hacky...
WALLET="$(cat /var/tmp/autorenew_bip32)"
CURRENCY="$(cat /var/tmp/autorenew_currency)"

sporestackv2 topup "$HOSTNAME" --days "$DAYS" --currency "$CURRENCY" --walkingliberty_wallet "$WALLET" || alert
