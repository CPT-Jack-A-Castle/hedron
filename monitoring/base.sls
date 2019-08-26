# gunicorn3 is for graphite-api
hedron_monitoring_packages:
  pkg.installed:
    - pkgs:
      - graphite-api
      - graphite-carbon
      - gunicorn3

hedron_monitoring_carbon_config:
  file.managed:
    - name: /etc/carbon/carbon.conf
    - source: salt://hedron/monitoring/files/carbon.conf.jinja
    - template: jinja

hedron_monitoring_carbon_storage_schemas_conf:
  file.managed:
    - name: /etc/carbon/storage-schemas.conf
    - source: salt://hedron/monitoring/files/storage-schemas.conf

hedron_monitoring_carbon_service:
  service.running:
    - name: carbon-cache
    - enable: True
    - watch:
      - file: /etc/carbon/carbon.conf

hedron_monitoring_graphite_api_drop_init_d:
  file.absent:
    - name: /etc/init.d/graphite-api

# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=826020;msg=5
hedron_monitoring_graphite_api_fix:
  file.replace:
    - name: /lib/systemd/system/graphite-api.service
    - pattern: RequireMountsFor
    - repl: RequiresMountsFor

hedron_monitoring_graphite_api_socket:
  file.replace:
    - name: /lib/systemd/system/graphite-api.socket
    - pattern: 127.0.0.1:8542
    - repl: 127.0.0.1:8081

hedron_monitoring_graphite_api_service:
  service.running:
    - name: graphite-api
    - enable: True
    - watch:
      - file: /lib/systemd/system/graphite-api.service

hedron_monitoring_graphite_api_service_socket:
  service.running:
    - name: graphite-api.socket
    - enable: True
    - watch:
      - file: /lib/systemd/system/graphite-api.socket

# The above "hedron_monitoring_graphite_api_service_socket" should work, but doesn't. This is a hack.
hedron_monitoring_graphite_api_service_socket_restart_manually_if_needed:
  cmd.run:
    - name: systemctl restart graphite-api.socket
    - onlyif: 'ss -ntpl | grep gunicorn3 | grep 127.0.0.1:8542'
