#!/bin/sh

set -e

BRAINVAULT_HASH=$(cat ~/.brainvault/hash)

# shellcheck disable=SC2012
service=$(ls -1 ~/.brainvault/logins | dmenu)

# Update mtime if there, create if not there.
touch ~/.brainvault/logins/"$service"

password=$(brainkey password "$BRAINVAULT_HASH" "$service")

xdotool sleep 1 type "$password"
