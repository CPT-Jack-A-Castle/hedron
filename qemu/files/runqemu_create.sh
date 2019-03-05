#!/bin/sh

# Not for direct consumption.

# FIXME: This script should become shorter in time and be replaced entirely by vmmanagement_run_create.py

# Default bootorder: disk, then network
BOOTORDER="cn"

set -e

umask 0022

fail() {
    echo "$@"
    exit 1
}

[ "$#" -gt 1 ] || fail 'Need arguments.'

# Now MACHINE_ID, more accurately.
UUID=$1
SLOT=$2

SLOTDIR="/home/vmmanagement/$UUID"
echo "$BOOTORDER" > "$SLOTDIR/bootorder"
TFTPVMDIR=$SLOTDIR/tftp
mkdir "$TFTPVMDIR"
touch "$TFTPVMDIR/boot.ipxe"

chown vmmanagement "$TFTPVMDIR/boot.ipxe" "$SLOTDIR/bootorder"

echo "
[Unit]
Description=Start slot$SLOT on path change

[Path]
Unit=runqemu_start@$UUID.service
PathChanged=/home/vmmanagement/$UUID/start

[Install]
WantedBy=multi-user.target
" > "/etc/systemd/system/runqemu_start_$UUID.path"

echo "
[Unit]
Description=Stop slot$SLOT on path change

[Path]
Unit=runqemu_stop@$UUID.service
PathChanged=/home/vmmanagement/$UUID/stop

[Install]
WantedBy=multi-user.target
" > "/etc/systemd/system/runqemu_stop_$UUID.path"

systemctl enable "runqemu_stop_$UUID.path"
systemctl start "runqemu_stop_$UUID.path"
systemctl enable "runqemu_start_$UUID.path"
systemctl start "runqemu_start_$UUID.path"

# We don't start VMs by default any more.
# systemctl start "runqemu@$UUID"

# Client is responsible for starting, but we will enable.
# This doesn't make complete sense and can be improved.
systemctl enable "runqemu@$UUID"

# Signal that we are done.
touch "$SLOTDIR"/created
