#!/bin/sh

set -e

fail() {
    echo "$@" >&2
    echo Aborting... >&2
    exit 1
}

USAGE="Usage: $0: <brainkey> <public|private>"

[ $# != 2 ] && fail "$USAGE"

# This won't be the hash when the workstation runs brainvault-ssh for the first time, but generally it is.
# It still works either way.
BRAINVAULT_HASH=$1
KEY=$2

PUBLIC_KEY_FILE="id_rsa.pub"
PRIVATE_KEY_FILE="id_rsa"

if [ "$KEY" = "public" ]; then
    KEY_FILE="$PUBLIC_KEY_FILE"
elif [ "$KEY" = "private" ]; then
    KEY_FILE="$PRIVATE_KEY_FILE"
else
    fail "$USAGE"
fi

umask 0077

TEMPDIR=$(mktemp -d)

cd "$TEMPDIR"

# Start generating the new key type.
# This makes $PRIVATE_KEY_FILE and $PUBLIC_KEY_FILE
# Also writes "Generating key..." to stdout. Let's silence that so it doesn't
# mixed up with the key itself.
# We were using ed25519 keys, but that type produces bad output with ssh-keydgen. Instead, we use rsa now.
# That should be fixed. Let's stick for RSA for now but consider going back.
brainkey password_hash "$BRAINVAULT_HASH" ssh_key | /var/golang/bin/ssh-keydgen -f "$PRIVATE_KEY_FILE" -t rsa > /dev/null

cat "$KEY_FILE"

cd "$OLDPWD"

rm -rf "$TEMPDIR"
