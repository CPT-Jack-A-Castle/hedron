#!/bin/sh

set -e

usage() {
    echo "$0: <public ssh key file>"
    exit 1
}

[ "$#" -ne 1 ] && usage

SSHKEYFILE=$1

SSHKEY=$(cat "$SSHKEYFILE")

# shellcheck disable=SC2016,SC2086
echo '#!ipxe

dhcp

set base-url http://stable.release.core-os.net/amd64-usr/current
kernel ${base-url}/coreos_production_pxe.vmlinuz initrd=coreos_production_pxe_image.cpio.gz sshkey="'$SSHKEY'"
initrd ${base-url}/coreos_production_pxe_image.cpio.gz
boot'
