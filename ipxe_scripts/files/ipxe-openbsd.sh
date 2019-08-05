#!/bin/sh

set -e

usage() {
    echo "$0"
    exit 1
}

[ "$#" -ne 0 ] && usage

# shellcheck disable=SC2016,SC2086
echo '#!ipxe

dhcp

echo This does not work over serial
imgfree
initrd http://ftp.openbsd.org/pub/OpenBSD/6.5/amd64/cd65.iso
chain https://boot.netboot.xyz/memdisk iso raw
exit'

# https on the ftp.openbsd.org site gives me Operation Not Permitted, http://ipxe.org/err/410de1
# http seems fine, though.
# memdisk https works.
