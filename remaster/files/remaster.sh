#!/bin/sh

# Startup script for image builder.

set -e

umask 0077

BASEDIR="/var/tmp/remaster-root"

mkdir "$BASEDIR" || true

cd "$BASEDIR"

# Hacky.
rm -r loop upper work overlay || true
mkdir loop upper work overlay || true

# Loop will be R/O
mount -o loop /srv/salt/dist/debian-stretch.iso loop

mount -t overlay -o lowerdir=loop,upperdir=upper,workdir=work overlayfs overlay

# Timeout units are tenths of a second.
# Eventually, should move this to vagabondworkstation's salt or make this generic.
echo "default vagabondworkstation
prompt 1
timeout 50
label vagabondworkstation
        menu label Mostly automated install
        kernel /install.amd/vmlinuz
        append net.ifnames=0 auto=true priority=critical initrd=/install.amd/initrd.gz preseed/file=/cdrom/preseed.cfg hostname=vagabondworkstation" > "$BASEDIR"/overlay/isolinux/isolinux.cfg

cp /srv/salt/hedron/remaster/files/workstation.debian_preseed "$BASEDIR"/overlay/preseed.cfg

cd overlay

cp -r /srv/salt salt

# This is pretty big and unnecessary for the most part.
rm salt/dist/debian-stretch.iso

# Don't write out the ISO with world readable flags.
xorriso -as mkisofs \
    -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
    -c isolinux/boot.cat \
    -b isolinux/isolinux.bin \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    -eltorito-alt-boot \
    -e boot/grub/efi.img \
    -no-emul-boot \
    -isohybrid-gpt-basdat \
    -o "/var/tmp/hedron.iso" \
    .

# pwd is about to explode. We need to get out so we can unmount things easily.
cd /

umount "$BASEDIR"/loop

umount "$BASEDIR"/overlay

echo Success

