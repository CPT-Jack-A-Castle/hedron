#!/bin/sh

# FIXME: alert if lock stays open! We need to know if we have any failures here. Very urgent.
# FIXME: alert on errors.

set -e

[ $# -ne 2 ] && exit 1

IPXE_SCRIPT=$1

DEST=$2

cd /usr/local/src/ipxe/src

# shellcheck disable=SC2016
flock . sh -c "set -e; alert() { echo "'$1'"; false; }; test -f bin/ipxe.iso && alert 'ipxe.iso exists'; make bin/ipxe.iso EMBED=$IPXE_SCRIPT; mv bin/ipxe.iso $DEST"
