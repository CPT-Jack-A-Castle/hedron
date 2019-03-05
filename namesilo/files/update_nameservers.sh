#!/bin/sh

FINISHED_FILE='/var/tmp/updated_nameservers'

set -e

if [ -f "$FINISHED_FILE" ]; then
    echo "$FINISHED_FILE exists. We should not have been called. Aborting!" >&2
    exit 1
fi

# Provides API_KEY, DOMAIN, IP4, IP6
# shellcheck disable=SC1091
. /etc/update_nameservers.cfg

INDEX=$(hostname | tr -d '\n' | tail -c 1)

namesiren set_ns_domain "$API_KEY" "$DOMAIN" "$INDEX" "$IP4" "$IP6"

touch "$FINISHED_FILE"
