#!/bin/sh

set -e

# Must be ran from this directory.

if [ $# = 0 ]; then
    echo "Usage: $0 <host>"
    exit 1
fi

HOST=$1

shift

salt/hedron/salt_utilities/files/sync_salt.sh "$HOST" "$*"

ssh -l root "$HOST" "$@" 'salt-call --retcode-passthrough -l info --local state.highstate'

echo Success
