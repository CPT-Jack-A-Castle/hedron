# There's the netinst package which doesn't include the bare minimum install. The "next size up" is XFCE, which we need X anyways, so shouldn't have a whole lot of overhead.
# Firmware is probably only needed for wifi and install will most likely happen over ethernet, so that can be installed as a package.

hedron_remaster_debian_stretch_iso:
  file.managed:
    - name: /srv/salt/dist/debian-stretch.iso
    - source:
      - salt://dist/debian-stretch.iso
      - https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-9.9.0-amd64-xfce-CD-1.iso
    - source_hash: 6fa24e8e305bdfd762605f092c2dcddb2e76f8522cb9a5035df88532d28c9a50
    - makedirs: True

hedron_remaster_debian_packages:
  pkg.installed:
    - pkgs:
      - genisoimage
      - rsync
      - xorriso
      - isolinux
