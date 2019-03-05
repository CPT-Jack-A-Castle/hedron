#!/bin/sh

set -e

usage() {
    echo "$0: <target> <options for salt-ssh>"
    exit 1
}

[ $# -lt 2 ] && usage

TARGET=$1
shift

PRIV_KEY_FILE=$(keyplease private "$TARGET")

salt-ssh --priv "$PRIV_KEY_FILE" --no-host-keys -c salt/hedron/salt_utilities/files/ --log-file /dev/null --roster-file salt/roster "$TARGET" "$@"
