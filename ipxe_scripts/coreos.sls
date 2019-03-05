hedron_ipxe_scripts_coreos_script:
  file.managed:
    - name: /usr/local/bin/ipxe-coreos-stable
    - source: salt://hedron/ipxe_scripts/files/ipxe-coreos-stable.sh
    - mode: 0755
