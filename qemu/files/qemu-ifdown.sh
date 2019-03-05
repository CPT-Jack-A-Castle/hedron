#!/bin/sh

set -e

vm_interface=$1

# ebtables
vmmanagement_interface down "$(vmmanagement_interface slot_to_vm "$vm_interface")"

brctl delif primary "$vm_interface"

ip l s "$vm_interface" down

echo 'Success.'
