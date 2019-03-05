include:
  - .packages

hedron_obfs4_server_torrc:
  file.managed:
    - name: /etc/tor/obfs4_server.torrc
    - source: salt://hedron/obfs4/files/server.torrc
    - require:
      - cmd: go get git.torproject.org/pluggable-transports/obfs4.git/obfs4proxy

hedron_obfs4_server_restart_tor:
  service.running:
    - name: tor@obfs4_server
    - watch:
      - file: /etc/tor/obfs4_server.torrc
