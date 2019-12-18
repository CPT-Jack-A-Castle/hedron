hedron_ipxe_dependencies:
  pkg.installed:
    - pkgs:
      - git
      - genisoimage
      - debhelper
      - dh-exec
      - syslinux-common
      - syslinux-utils
      - dosfstools
      - mtools
      - binutils-dev
      - liblzma-dev
      - build-essential
      - xorriso
      - isolinux
      - zlib1g-dev

hedron_ipxe_source_archive:
  file.managed:
    - name: /srv/salt/dist/ipxe.tar.gz
    - source:
      - salt://dist/ipxe.tar.gz
      - http://git.ipxe.org/ipxe.git/snapshot/53af9905e023c89c9d7c30c22eb25f2b0105026c.tar.gz
    - source_hash: 640ed8aa2e571217fdf9ac65a20692a3f89a04f2ee141e65efdadcca8cc131d4
    - makedirs: True

hedron_ipxe_source_directory:
  file.directory:
    - name: /usr/local/src/ipxe

hedron_ipxe_source_extracted:
  cmd.run:
    - name: tar -xzf /srv/salt/dist/ipxe.tar.gz -C /usr/local/src/ipxe --strip-components=1
    - creates: /usr/local/src/ipxe/README

hedron_ipxe_patch:
  cmd.script:
    - source: salt://hedron/ipxe/files/ipxe_patch.sh
    - creates: /usr/local/src/ipxe/.patched
    - cwd: /usr/local/src/ipxe

hedron_ipxe_build:
  cmd.run:
    - name: make bin/ipxe.iso && touch /usr/local/src/ipxe/.built
    - cwd: /usr/local/src/ipxe/src
    - creates: /usr/local/src/ipxe/.built

hedron_ipxe_permissions:
  file.directory:
    - name: /usr/local/src/ipxe
    - mode: 0755
    - user: vmmanagement
    - recurse:
      - user

# ipxescript fails if iso exists, so be careful about this
# FIXME: use file.mv?
hedron_ipxe_stock_iso:
  cmd.run:
    - name: mv /usr/local/src/ipxe/src/bin/ipxe.iso /var/tmp/ipxe_stock.iso
    - creates: /var/tmp/ipxe_stock.iso
