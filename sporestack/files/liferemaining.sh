#!/bin/sh

set -e

usage() {
    echo "$0: <statsd identifier> <future epoch>"
    exit 2
}

[ $# -ne 2 ] && usage

STATSD_ID=$1
EPOCH_TIME=$2

EPOCH=$(date +%s)

TIME_LEFT=$((EPOCH_TIME - EPOCH))

STATSD_MESSAGE="$STATSD_ID:$TIME_LEFT|g"

echo "$STATSD_MESSAGE" | nc -w 0 -u 127.0.0.1 8125
echo "$STATSD_MESSAGE"
