hedron_ipxe_scripts_mfsbsd_script:
  file.managed:
    - name: /usr/local/bin/ipxe-mfsbsd
    - source: salt://hedron/ipxe_scripts/files/ipxe-mfsbsd.sh
    - mode: 0755
