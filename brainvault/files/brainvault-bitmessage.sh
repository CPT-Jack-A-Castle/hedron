#!/bin/sh

set -e

BRAINVAULT="$1"

usage() {
    echo "Usage: $0 <brainkey>" >&2
    exit 1
}

# If it's not set, print usage and quit.
[ -z "$BRAINVAULT" ] && usage

abort() {
    echo "$1"
    exit 1
}

grep -q bitmessage_address_generator /var/lib/notbit/keys.dat 2> /dev/null && abort "bitmessage_address_generator already in /var/lib/notbit/keys.dat, refusing to overwrite"

if [ -w '/var/lib/notbit/keys.dat' ]; then
    bitmessage_address_generator "$BRAINVAULT" > /var/lib/notbit/keys.dat
else
    abort "Unable to overwrite /var/lib/notbit/keys.dat. Are you user@?"
fi
