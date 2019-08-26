#!/bin/sh

set -e

usage() {
    echo "$0"
    exit 2
}

[ $# -ne 0 ] && usage

STATSD_ID=uptime

# Don't need hundreth of a second precision here.
UPTIME=$(cut -d ' ' -f 1 /proc/uptime | cut -d . -f 1)

STATSD_MESSAGE="$STATSD_ID:$UPTIME|g"

echo "$STATSD_MESSAGE" | nc -w 0 -u 127.0.0.1 8125
echo "$STATSD_MESSAGE"
