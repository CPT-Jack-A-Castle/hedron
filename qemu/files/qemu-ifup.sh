#!/bin/sh

set -e

vm_interface=$1

# ebtables
vmmanagement_interface up "$(vmmanagement_interface slot_to_vm "$vm_interface")"

brctl addif primary "$vm_interface"

ip l s "$vm_interface" up

echo 'Success.'
