#!/bin/sh

set -e

usage() {
    echo "$0"
    exit 2
}

[ $# -ne 0 ] && usage

STATSD_ID=failed_systemd_units

FAILED_COUNT=$(systemctl list-units --state=failed | grep -c 'failed')

STATSD_MESSAGE="$STATSD_ID:$FAILED_COUNT|g"

echo "$STATSD_MESSAGE" | nc -w 0 -u 127.0.0.1 8125
echo "$STATSD_MESSAGE"
