include:
  - .config

hedron_ngircd_service_running:
  service.running:
    - name: ngircd
    - enable: True
    - watch:
      - file: /etc/ngircd/ngircd.conf
