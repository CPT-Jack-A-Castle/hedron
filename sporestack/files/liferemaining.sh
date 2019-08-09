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

# Don't go negative, partly because it behaves as a delta
if [ $TIME_LEFT -lt 0 ]; then
    TIME_LEFT=0
fi

STATSD_MESSAGE="$STATSD_ID:$TIME_LEFT|g"

echo "$STATSD_MESSAGE" | nc -w 0 -u 127.0.0.1 8125
echo "$STATSD_MESSAGE"
