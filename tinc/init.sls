hedron_tinc_package:
  pkg.installed:
    - name: tinc

hedron_tinc_stop_stock_service:
  service.dead:
    - name: tinc
    - enable: False

hedron_tinc_purge_old_service_file:
  file.absent:
    - name: /lib/systemd/system/tinc.service

hedron_tinc_service_file:
  file.managed:
    - name: /lib/systemd/system/tinc@.service
    - source: salt://hedron/tinc/files/tinc@.service
