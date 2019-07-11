hedron_ipxe_scripts_buster_preseed:
  file.managed:
    - name: /usr/local/share/ipxe-buster.debian_preseed
    - source: salt://hedron/ipxe_scripts/files/ipxe-buster.debian_preseed

hedron_ipxe_scripts_buster_script:
  file.managed:
    - name: /usr/local/bin/ipxe-buster
    - source: salt://hedron/ipxe_scripts/files/ipxe-buster.sh
    - mode: 0755
