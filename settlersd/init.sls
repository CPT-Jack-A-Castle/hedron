# Built from https://github.com/sporestack/settlers

{% set hash = 'b157f4401ed4c961e7184d26d7feca22fc74e067deba0a19fae17be2076a41c7' %}

hedron_settlersd_installed:
  file.managed:
    - name: /usr/local/bin/settlersd
    - source:
      - /srv/files/decensor/assets/{{ hash }}
      - https://go-beyond.org/decensor/asset/{{ hash }}
    - source_hash: {{ hash }}
    - mode: 0755

hedron_settlersd_configuration:
  file.serialize:
    - name: /var/lib/settlersd/settlersd.json
    - dataset_pillar: hedron.settlersd
    - mode: 0400
    - formatter: json
    - makedirs: True

# settlersd listens on :2828
hedron_settlersd_service_file:
  file.managed:
    - name: /etc/systemd/system/settlersd.service
    - source: salt://hedron/settlersd/files/settlersd.service
    - check_cmd: systemd-analyze verify
    - tmp_ext: .service

hedron_settlersd_service_running:
  service.running:
    - name: settlersd
    - enable: True
    - watch:
      - file: /etc/systemd/system/settlersd.service
      - file: /usr/local/bin/settlersd
