hedron_ipxe_scripts_openbsd_script:
  file.managed:
    - name: /usr/local/bin/ipxe-openbsd
    - source: salt://hedron/ipxe_scripts/files/ipxe-openbsd.sh
    - mode: 0755
