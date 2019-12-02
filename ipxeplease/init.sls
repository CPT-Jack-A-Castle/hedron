# Built from https://github.com/teran-mckinney/ipxeplease

# Previous: e54faa7da702def1aaf17093416aa48cb7be1d72ae3888eccacbba4120d38d6b
# Latest: dd6cd41d914dcf56675e13555fe3ba216569a180d58c605f3a58d7d3f2185daa

{% set hash = 'dd6cd41d914dcf56675e13555fe3ba216569a180d58c605f3a58d7d3f2185daa' %}

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
