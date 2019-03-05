#!/bin/sh

# This is a helper to give different SSH keys per host. The keys are random and saved to disk. These are more intended for initial keys than management, but can do either depending on the context. This helps prevent identity correlation via identical SSH keys. Generated keys are random. Always returns a key, including defaults to have something to try. It's designed to be backwards compatible.

set -e

umask 0077

fail() {
    echo "$1" >&2
    exit 1
}

usage() {
    fail "Usage: $0 <generate|private|public> <host>"
}

[ $# -eq 2 ] || usage

COMMAND=$1
HOST=$2


if [ "$(whoami)" = 'root' ]; then
    KEYPLEASE_DIR=/etc/keyplease
    # This fallback is legacy and not created on new systems.
    FALLBACK_KEY=/etc/ssh/id_rsa
else
    KEYPLEASE_DIR=~/.keyplease
    FALLBACK_KEY=~/.ssh/id_rsa
fi

generate() {
    [ -d "$KEYPLEASE_DIR" ] || mkdir "$KEYPLEASE_DIR"
    host=$1
    private_key="$KEYPLEASE_DIR/$host"
    public_key="$KEYPLEASE_DIR/$host.pub"
    [ -f "$public_key" ] && fail "keyplease already exists: $public_key"
    [ -f "$private_key" ] && fail "keyplease already exists: $private_key"
    ssh-keygen -b 2048 -t rsa -C '' -N '' -f "$private_key" > /dev/null
}

getkey() {
    host=$1
    suffix=$2
    for possible_key in "$KEYPLEASE_DIR/$host$suffix" "$FALLBACK_KEY$suffix"; do
        if [ -r "$possible_key" ]; then
            echo "$possible_key"
            break
        fi
    done
}

case "$COMMAND" in
    generate)
        generate "$HOST"
        ;;
    private)
        getkey "$HOST" ''
        ;;
    public)
        getkey "$HOST" '.pub'
        ;;
    *)
        usage
        ;;
esac
