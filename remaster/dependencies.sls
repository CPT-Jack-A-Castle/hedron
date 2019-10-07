# There's the netinst package which doesn't include the bare minimum install. The "next size up" is XFCE, which we need X anyways, so shouldn't have a whole lot of overhead.
# Firmware is probably only needed for wifi and install will most likely happen over ethernet, so that can be installed as a package.

#hedron_remaster_debian_stretch_iso:
#  file.managed:
#    - name: /srv/salt/dist/debian-stretch.iso
#    - source:
#      - salt://dist/debian-stretch.iso
#      - https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-9.9.0-amd64-xfce-CD-1.iso
#    - source_hash: 6fa24e8e305bdfd762605f092c2dcddb2e76f8522cb9a5035df88532d28c9a50
#    - makedirs: True
#
#hedron_remaster_debian_stretch_firmware:
#  file.managed:
#    - name: /srv/salt/dist/debian-stretch-firmware.tar.gz
#    - source:
#      - https://cdimage.debian.org/cdimage/unofficial/non-free/firmware/stretch/20190427/firmware.tar.gz
#    - source_hash: da7282396bec024eaf3a121621c8136a6c0ddc60f8563f9e31f9bb41867d411a
#    - makedirs: True

hedron_remaster_debian_buster_iso:
  file.managed:
    - name: /srv/salt/dist/debian-buster.iso
    - source:
      - https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-10.1.0-amd64-xfce-CD-1.iso
    - source_hash: 2d6da2d422cbc27a396d53b94b9bf2d7637e926d6392d4e90d4e18012575562d
    - makedirs: True

hedron_remaster_debian_buster_firmware:
  file.managed:
    - name: /srv/salt/dist/debian-buster-firmware.tar.gz
    - source:
      - https://cdimage.debian.org/cdimage/unofficial/non-free/firmware/buster/20190908/firmware.tar.gz
    - source_hash: 89505e4e9f20acc07146390d0b9e086607d940786191dd6222093271acd23934
    - makedirs: True

#hedron_remaster_debian_buster_iso:
#  file.managed:
#    - name: /srv/salt/dist/debian-buster.iso
#    - source:
#      - https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-10.0.0-amd64-xfce-CD-1.iso
#    - source_hash: 5714b75bbf02c61c2eacad51b6042efd0806fcc60180ad9029f15cace21119fb
#    - makedirs: True
#
#hedron_remaster_debian_buster_firmware:
#  file.managed:
#    - name: /srv/salt/dist/debian-buster-firmware.tar.gz
#    - source:
#      - https://cdimage.debian.org/cdimage/unofficial/non-free/firmware/buster/20190706/firmware.tar.gz
#    - source_hash: 95d1d45598a138fa2f0668b752aac3f9170191b3bda0df6d8ffcc93270284484
#    - makedirs: True

hedron_remaster_debian_packages:
  pkg.installed:
    - pkgs:
      - genisoimage
      - rsync
      - xorriso
      - isolinux
