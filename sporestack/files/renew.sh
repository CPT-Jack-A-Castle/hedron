#!/bin/sh

set -e

alert() {
    echo 'CRITICAL: renewal failure'
    exit 1
}

HOSTNAME=$(hostname)
DAYS=7
# This is so hacky...
WALLET="$(cat /var/tmp/autorenew_bip32)"
CURRENCY="$(cat /var/tmp/autorenew_currency)"

sporestackv2 topup "$HOSTNAME" --days "$DAYS" --currency "$CURRENCY" --walkingliberty_wallet "$WALLET" || alert

EXPIRES=$(sporestackv2 get_attribute "$HOSTNAME" expiration)

RENEWAL=$(date --date=@$((EXPIRES - 86400)) +%Y%m%d%H%M)

# TODO: Should replace at with systemd.
echo "$0" | at -t "$RENEWAL"
