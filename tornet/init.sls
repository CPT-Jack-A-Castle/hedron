include:
  - .notor_user
  - hedron.tor
  - hedron.tor.carml
  - hedron.iptables

hedron_tornet_tor_service_file:
  file.managed:
    - name: /etc/systemd/system/tornet@.service
    - source: salt://hedron/tornet/files/tornet@.service

hedron_tornet_tor_service_running:
  service.running:
    - name: tornet@13999
    - enable: True

# Install ntp for ntp user so that iptables will work.
# Kinda silly and we might move to systemd's timesyncd anyway.
hedron_tornet_packages:
  pkg.installed:
    - pkgs:
      - ntp

hedron_tornet_iptables_rules:
  file.managed:
    - name: /etc/iptables.rules
    - source: salt://hedron/tornet/files/iptables.rules.jinja
    - template: jinja

