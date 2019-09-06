{% set hash = '39f181e832fb786d1170906e06cd3ac570c5376a0cdcd6bbd85306c01dcb2ab8' %}

# Build with ./test.sh in sslexpirystatsd repository.

hedron_sslexpirystatsd_installed:
  file.managed:
    - name: /usr/local/bin/sslexpirystatsd
    - source:
      - /srv/files/decensor/assets/{{ hash }}
      - https://go-beyond.org/decensor/asset/{{ hash }}
    - source_hash: {{ hash }}
    - mode: 0755

hedron_sslexpirystatsd_configuration_file:
  file.serialize:
    - name: /etc/sslexpirystatsd.json
    - dataset_pillar: hedron.sslexpirystatsd
    - mode: 0644
    - formatter: json
# https://github.com/saltstack/salt/issues/53982
#    - check_cmd: hivemind get_config --config_file
# Hack for now:
hedron_sslexpirystatsd_configuration_file_validate:
  cmd.run:
    - name: sslexpirystatsd validate_configuration /etc/sslexpirystatsd.json
    - unless: sslexpirystatsd validate_configuration /etc/sslexpirystatsd.json

hedron_sslexpirystatsd_service_file:
  file.managed:
    - name: /etc/systemd/system/sslexpirystatsd.service
    - source: salt://hedron/sslexpirystatsd/files/sslexpirystatsd.service
    - check_cmd: systemd-analyze verify
    - tmp_ext: .service

hedron_sslexpirystatsd_service_timer_file:
  file.managed:
    - name: /etc/systemd/system/sslexpirystatsd.timer
    - source: salt://hedron/sslexpirystatsd/files/sslexpirystatsd.timer
    - check_cmd: systemd-analyze verify
    - tmp_ext: .timer

hedron_sslexpirystatsd_service_timer_running:
  service.running:
    - name: sslexpirystatsd.timer
    - enable: True
