#!/bin/sh

set -e

# When we get a non-zero exit code for a getbalance call, we assume the daemon is ready enough.
# This is a totally random address that we don't have the private key to.
until /srv/electrum/electrum -D /run/electrum getaddressbalance 15Ghyee2Xyj8n9idpmsFv6ZkAWjotZcAoV 2> /dev/null; do
    sleep 5
done
