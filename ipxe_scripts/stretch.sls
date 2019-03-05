hedron_ipxe_scripts_stretch_preseed:
  file.managed:
    - name: /usr/local/share/ipxe-stretch.debian_preseed
    - source: salt://hedron/ipxe_scripts/files/ipxe-stretch.debian_preseed

hedron_ipxe_scripts_stretch_script:
  file.managed:
    - name: /usr/local/bin/ipxe-stretch
    - source: salt://hedron/ipxe_scripts/files/ipxe-stretch.sh
    - mode: 0755
