hedron_proxychains_pkg:
  pkg.installed:
    - name: proxychains-ng

hedron_proxychains_config:
  file.managed:
    - name: /etc/proxychains.conf
    - source: salt://hedron/proxychains/files/proxychains.conf
