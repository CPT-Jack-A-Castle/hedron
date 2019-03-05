#!/bin/sh

# Usage: ipxe-ubuntu-desktop <release> (--vga)

# Ubuntu desktop without any kind of Salt/SSH configuration.

# FIXME: Lots of redundancy.

set -e

umask 0022

RELEASE=$1

CONSOLE="console=ttyS0,115200n8"
[ "$2" = "--vga" ] && CONSOLE=""

PRESEEDSUFFIX='ipxe-ubuntu-desktop.debian_preseed'

PRESEEDSOURCE="/usr/local/share/$PRESEEDSUFFIX"

# For relative work.
[ -f "$PRESEEDSOURCE" ] || PRESEEDSOURCE="salt/hedron/ipxe_scripts/files/$PRESEEDSUFFIX"

PRESEEDFILE="$PRESEEDSOURCE"

CHECKSUM=$(md5sum "$PRESEEDFILE" | awk '{print $1}')

PRESEED=$(pasteit < "$PRESEEDFILE")

STARTUPSCRIPT=$(mktemp)

# shellcheck disable=SC2016
# shellcheck disable=SC2086
# Inject URL into iPXE script
echo '#!ipxe

dhcp

set mirror http://archive.ubuntu.com/ubuntu/dists/'$RELEASE'-updates/main/installer-amd64/current/images/netboot/ubuntu-installer/amd64
kernel ${mirror}/linux '$CONSOLE' net.ifnames=0 netcfg/choose_interface=eth0 initrd=initrd.gz auto=true priority=critical hostname='$RELEASE' auto auto preseed/url='$PRESEED' preseed-md5='$CHECKSUM' debian-installer/allow_unauthenticated_ssl=true
initrd ${mirror}/initrd.gz
boot' > "$STARTUPSCRIPT"

cat "$STARTUPSCRIPT"

unlink "$STARTUPSCRIPT"
