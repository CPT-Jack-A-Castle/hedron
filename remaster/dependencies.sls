# Can also use this for non-firmware image: http://cdimage.debian.org/cdimage/release/current/amd64/iso-cd/debian-9.9.0-amd64-netinst.iso

hedron_remaster_debian_stretch_iso:
  file.managed:
    - name: /srv/salt/dist/debian-stretch.iso
    - source:
      - salt://dist/debian-stretch.iso
      - http://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/9.9.0+nonfree/amd64/iso-cd/firmware-9.9.0-amd64-netinst.iso
    - source_hash: 13f477ccf777a56a78eed085c12594432ac645a2f024c2a0006cec38f27aeaf8
    - makedirs: True

hedron_remaster_debian_packages:
  pkg.installed:
    - pkgs:
      - genisoimage
      - rsync
      - xorriso
      - isolinux
