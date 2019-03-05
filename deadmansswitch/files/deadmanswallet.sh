#!/bin/sh

set -e


WALLET=$(cat /var/tmp/deadmanswallet)

DESTINATION=1FIXME

BALANCE=$(walkingliberty balance "$WALLET")

# 32,000 for dust and TX fees
COMMAND="walkingliberty send $WALLET $DESTINATION $((BALANCE - 32000))"

if [ "$BALANCE" = "0" ]; then
    echo "Notice: zero balance."
fi

if [ "$1" = "--audit" ]; then
    echo "Audit mode. Would have ran: $COMMAND"
else
    # If command fails, try to run it again in five minutes.
    $COMMAND || echo '/usr/local/sbin/deadmanswallet' | at +5m
fi

echo 'Success'
