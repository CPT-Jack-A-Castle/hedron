hedron_ipxe_scripts_ubuntu-desktop_preseed:
  file.managed:
    - name: /usr/local/share/ipxe-ubuntu-desktop.debian_preseed
    - source: salt://hedron/ipxe_scripts/files/ipxe-ubuntu-desktop.debian_preseed

hedron_ipxe_scripts_ubuntu-desktop_script:
  file.managed:
    - name: /usr/local/bin/ipxe-ubuntu-desktop
    - source: salt://hedron/ipxe_scripts/files/ipxe-ubuntu-desktop.sh
    - mode: 0755
