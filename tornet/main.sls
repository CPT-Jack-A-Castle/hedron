include:
  - hedron.tor
  - hedron.tor.carml
  - hedron.iptables

hedron_tornet_main_tor_service_file:
  file.managed:
    - name: /etc/systemd/system/tornet@.service
    - source: salt://hedron/tornet/files/tornet@.service

hedron_tornet_main_tor_service_running:
  service.running:
    - name: tornet@13999
    - enable: True
