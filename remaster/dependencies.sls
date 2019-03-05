# Can also use this for non-firmware image: http://cdimage.debian.org/cdimage/release/current/amd64/iso-cd/debian-9.8.0-amd64-netinst.iso

hedron_remaster_debian_stretch_iso:
  file.managed:
    - name: /srv/salt/dist/debian-stretch.iso
    - source:
      - salt://dist/debian-stretch.iso
      - http://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/9.8.0+nonfree/amd64/iso-cd/firmware-9.8.0-amd64-netinst.iso
    - source_hash: bcdb63fbebbe30220142bdf60e0cbf50cf3163958802b2055490370def3bae0f
    - makedirs: True

hedron_remaster_debian_packages:
  pkg.installed:
    - pkgs:
      - genisoimage
      - rsync
      - xorriso
      - isolinux
