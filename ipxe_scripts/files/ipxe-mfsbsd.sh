#!/bin/sh

# NOT WORKING

set -e

usage() {
    echo "$0"
    echo "Password is mfsroot"
    echo "System is all in memory, does not reboot."
    exit 1
}

[ "$#" -ne 0 ] && usage

# shellcheck disable=SC2016,SC2086
echo '#!ipxe

dhcp

imgfree
echo This is mfsbsd (FreeBSD in memory) https://mfsbsd.vx.sk
echo root password is mfsroot
initrd https://mfsbsd.vx.sk/files/iso/12/amd64/mfsbsd-se-12.0-RELEASE-amd64.iso
chain https://boot.netboot.xyz/memdisk iso raw
exit'

# https on the mfsbsd.vx.sk site gives me Operation Not Permitted, http://ipxe.org/err/410de1
# http redirects to https, so no luck there. This is broken.
# memdisk seems fine, though.
