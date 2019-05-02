include:
  - hedron.pip
  - hedron.nginx

# FIXME: Designed for ssh port forwarding to get to the dashboard
# Example: ssh -L 8079:127.0.0.1:8079 -L 8081:127.0.0.1:8081 root@foo.onion

# gunicorn3 is for graphite-api
# nginx is for giraffe which pulls from graphite-api
hedron_monitoring_packages:
  pkg.installed:
    - pkgs:
      - graphite-api
      - graphite-carbon
      - gunicorn3

hedron_monitoring_nginx_config:
  file.managed:
    - name: /etc/nginx/sites-enabled/monitoring.conf
    - source: salt://hedron/monitoring/files/nginx.conf.jinja
    - template: jinja

hedron_monitoring_web_root:
  file.directory:
    - name: /var/www/monitoring
    - group: www-data
    - mode: 0750

hedron_monitoring_nginx_service:
  service.running:
    - name: nginx
    - enable: True
    - watch:
      - file: /etc/nginx/sites-enabled/monitoring.conf

hedron_monitoring_carbon_config:
  file.managed:
    - name: /etc/carbon/carbon.conf
    - source: salt://hedron/monitoring/files/carbon.conf.jinja
    - template: jinja

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

hedron_monitoring_girafee_fetch:
  file.managed:
    - name: /srv/salt/dist/giraffe.tar.gz
    - source:
      - salt://dist/giraffe.tar.gz
      - https://github.com/kenhub/giraffe/archive/1.3.1.tar.gz
    - source_hash: 8c24daa1828f9dba919bd393e77b8814de9ee10de8490d84d9305a39bf077655
    - makedirs: True

hedron_monitoring_giraffee_extracted:
  cmd.run:
    - name: tar -xzf /srv/salt/dist/giraffe.tar.gz -C /var/www/monitoring --strip-components=1
    - creates: /var/www/monitoring/index.html

hedron_monitoring_giraffee_settings:
  file.managed:
    - name: /var/www/monitoring/dashboards.js
    - source: salt://hedron/monitoring/files/dashboards.js.jinja
    - template: jinja

hedron_monitoring_graphite-beacon_install:
  pip.installed:
    - name: graphite-beacon
# I tried Python 3 on this. There's a pretty interesting, probably easy to fix bug.
# https://github.com/klen/graphite-beacon/issues/209
# It runs, but may not be usable. Sticking with Python 2 for now.
#    - bin_env: /usr/bin/pip3

# This one does not convert easily into pure pillar formats.
# Better just to provide the file and have the user jinja as needed.
# If you want a custom one, copy graphite-beacon.json.jinja
# into hedron_monitoring/files/. Note, hedron underscore monitoring,
# not hedron slash monitoring.
hedron_monitoring_graphite-beacon_config:
  file.managed:
    - name: /etc/graphite-beacon.json
    - source:
      - salt://hedron_monitoring/files/graphite-beacon.json.jinja
      - salt://hedron/monitoring/files/graphite-beacon.json.jinja
    - template: jinja

hedron_monitoring_graphite-beacon_service_file:
  file.managed:
    - name: /etc/systemd/system/graphite-beacon.service
    - source: salt://hedron/monitoring/files/graphite-beacon.service

# FIXME: Alarm reset interval is always 2 hours according to graphite-beacon logs?
# Also, can probably use "log" instead of cli mode with logger.
hedron_monitoring_graphite-beacon_service_running:
  service.running:
    - name: graphite-beacon
    - enable: True
    - watch:
      - file: /etc/systemd/system/graphite-beacon.service
      - file: /etc/graphite-beacon.json
