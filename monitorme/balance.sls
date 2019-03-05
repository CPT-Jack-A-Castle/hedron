# Requires sporestack.autorenew or develop_this / replication states as well...

include:
  - hedron.pip
  - hedron.walkingliberty

hedron_monitorme_balance_statsd:
  pip.installed:
    - pkgs:
      - statsd
      - sh
    - bin_env: /usr/bin/pip3

hedron_monitorme_balance_script:
  file.managed:
    - name: /usr/local/bin/balance
    - source: salt://hedron/monitorme/files/balance.py
    - mode: 0500

hedron_monitorme_balance_service_file:
  file.managed:
    - name: /etc/systemd/system/balance.service
    - source: salt://hedron/monitorme/files/balance.service

hedron_monitorme_balance_timer_file:
  file.managed:
    - name: /etc/systemd/system/balance.timer
    - source: salt://hedron/monitorme/files/balance.timer

hedron_monitorme_balance_timer_service:
  service.running:
    - name: balance.timer
    - enable: True
