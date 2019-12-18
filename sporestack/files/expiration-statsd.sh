#!/bin/sh

set -e

usage() {
    echo "$0 (No arguments)"
    exit 2
}

[ $# -ne 0 ] && usage

HOSTNAME=$(hostname)

liferemaining sporestack.expiration "$(sporestackv2 get_attribute "$HOSTNAME" expiration)"
