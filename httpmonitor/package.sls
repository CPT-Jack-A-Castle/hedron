include:
  - .dependencies

hedron_httpmonitor_package:
  file.managed:
    - name: /usr/local/bin/httpmonitor
    - source: salt://hedron/httpmonitor/files/httpmonitor.py
    - mode: 0755
