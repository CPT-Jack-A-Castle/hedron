#!/bin/sh

set -e

brainvault_hashed=$(cat ~/.brainvault/hash)
email_domain=$(cat ~/.brainvault/email_domain)
public_name=$(brainkey public "$brainvault_hashed")
hostname=$(hostname)

line="$public_name@$email_domain on $hostname"

# Give the same output on the console if there's no X.
if [ -n "$DISPLAY" ]; then
    xsetroot -name "$line"
else
    echo "$line"
fi
