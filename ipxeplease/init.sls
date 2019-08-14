# Built from https://github.com/teran-mckinney/ipxeplease

{% set hash = '27fba429b3948dea7bd25c9b80b500b9e012de27b3a31cab9a9e1aab98e12c84' %}

hedron_ipxeplease_installed:
  file.managed:
    - name: /usr/local/bin/ipxeplease
    - source:
      - /srv/files/decensor/assets/{{ hash }}
      - https://go-beyond.org/decensor/asset/{{ hash }}
    - source_hash: {{ hash }}
    - mode: 0755

# ipxeplease listens on :5555
hedron_ipxeplease_service_file:
  file.managed:
    - name: /etc/systemd/system/ipxeplease.service
    - source: salt://hedron/ipxeplease/files/ipxeplease.service.jinja
    - template: jinja
    - check_cmd: systemd-analyze verify
    - tmp_ext: .service

hedron_ipxeplease_service_running:
  service.running:
    - name: ipxeplease
    - enable: True
    - watch:
      - file: /etc/systemd/system/ipxeplease.service
      - file: /usr/local/bin/ipxeplease
