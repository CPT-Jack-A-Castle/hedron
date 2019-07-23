include:
  - hedron.pip

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
# FIXME: Replace with file.serialize
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
