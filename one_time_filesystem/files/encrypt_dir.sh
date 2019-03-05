#!/bin/sh

# DANGEROUS

set -e

# This is in case we replace /usr.
GOCRYPTFS=/gocryptfs
cp "$(which gocryptfs)" "$GOCRYPTFS"

[ -z "$1" ] && exit 1

DIR=$1
ENCRYPTED_TEMP_DIR="$DIR"_encrypted_temp
ENCRYPTED_WORK_DIR="$DIR"_encrypted_work

KEY=$(pwgen -s 40 1)

mkdir "$ENCRYPTED_TEMP_DIR"
mkdir "$ENCRYPTED_WORK_DIR"

echo "$KEY" | "$GOCRYPTFS" -init "$ENCRYPTED_WORK_DIR"

echo "$KEY" | "$GOCRYPTFS" -suid -allow_other "$ENCRYPTED_WORK_DIR" "$ENCRYPTED_TEMP_DIR"

rsync -ax "$DIR"/ "$ENCRYPTED_TEMP_DIR"

umount "$ENCRYPTED_TEMP_DIR"
rmdir "$ENCRYPTED_TEMP_DIR"

# We don't have to do this, but we should to help wipe out important bits that are there.
# We don't do a good job of considering ideal permissions on the folder, but hopefully they
# are fixed later in the process.
rm -rf "$DIR"
mkdir "$DIR"

# With fuse it seems to not be possible to move the mounted target, so had to unmount then
# remount, but needed the old directory around to seed it from with rsync.
echo "$KEY" | "$GOCRYPTFS" -suid -allow_other "$ENCRYPTED_WORK_DIR" "$DIR"

rm "$GOCRYPTFS"

# FIXME: This is super hacky. dbus breaks after /etc is updated. Restart dbus
if [ "$DIR" = "/etc" ]; then
    systemctl restart dbus
fi
