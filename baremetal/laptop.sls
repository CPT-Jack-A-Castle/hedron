# Laptop behaviors (suspend on lid close, etc)

hedron_baremetal_laptop_no_lid_closed_suspend_logind_conf:
  file.managed:
    - name: /etc/systemd/logind.conf
    - source: salt://hedron/baremetal/files/logind.conf

hedron_baremetal_laptop_no_lid_closed_suspend_logind_service:
  service.running:
    - name: systemd-logind
    - enable: True
    - watch:
      - file: /etc/systemd/logind.conf
