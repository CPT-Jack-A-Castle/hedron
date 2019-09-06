{% set hash = 'dd97c43ae2e938537dfcf0cad7ac835407fc109b831a74a063e1bd9b81de8b89' %}

# Build with ./test.sh in sslexpirystatsd repository.

hedron_sslexpirystatsd_installed:
  file.managed:
    - name: /usr/local/bin/sslexpirystatsd
    - source:
      - /srv/files/decensor/assets/{{ hash }}
      - https://go-beyond.org/decensor/asset/{{ hash }}
    - source_hash: {{ hash }}
    - mode: 0755

hedron_sslexpirystatsd_service_file:
  file.managed:
    - name: /etc/systemd/system/sslexpirystatsd@.service
    - source: salt://hedron/sslexpirystatsd/files/sslexpirystatsd@.service
    - check_cmd: systemd-analyze verify
    - tmp_ext: .service

hedron_sslexpirystatsd_service_timer_file:
  file.managed:
    - name: /etc/systemd/system/sslexpirystatsd@.timer
    - source: salt://hedron/sslexpirystatsd/files/sslexpirystatsd@.timer
    - check_cmd: systemd-analyze verify
    - tmp_ext: .timer

{% if 'hedron.sslexpirystatsd.hosts' in pillar %}
{% for host in pillar['hedron.sslexpirystatsd.hosts'] %}
hedron_sslexpirystatsd_service_{{ host }}_running:
  service.running:
    - name: sslexpirystatsd@{{ host }}.timer
    - enable: True
{% endfor %}
{% endif %}
