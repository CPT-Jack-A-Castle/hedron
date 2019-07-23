# Requires sporestack.autorenew or develop_this / replication states as well...

include:
  - hedron.pip
  - hedron.walkingliberty

hedron_monitorme_balance_statsd:
  pip.installed:
    - pkgs:
      - aaargh
      - statsd
    - bin_env: /usr/bin/pip3

hedron_monitorme_balance_script:
  file.managed:
    - name: /usr/local/bin/balance
    - source: salt://hedron/monitorme/files/balance.py
    - mode: 0755

hedron_monitorme_balance_configuration:
  file.serialize:
    - name: /etc/balance.json
    - dataset_pillar: hedron.monitorme.balance
    - formatter: json
    - mode: 0644
# https://github.com/saltstack/salt/issues/53982
#    - check_cmd: balance get_config --config_file
# Hack for now:
hedron_monitorme_balance_configuration_verify:
  cmd.run:
    - name: balance get_config --config_file /etc/balance.json
    - unless: balance get_config --config_file /etc/balance.json

hedron_monitorme_balance_service_file:
  file.managed:
    - name: /etc/systemd/system/balance.service
    - source: salt://hedron/monitorme/files/balance.service
    - check_cmd: systemd-analyze verify
    - tmp_ext: .service

hedron_monitorme_balance_timer_file:
  file.managed:
    - name: /etc/systemd/system/balance.timer
    - source: salt://hedron/monitorme/files/balance.timer
    - check_cmd: systemd-analyze verify
    - tmp_ext: .timer

hedron_monitorme_balance_timer_service:
  service.running:
    - name: balance.timer
    - enable: True
