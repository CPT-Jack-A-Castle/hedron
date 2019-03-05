include:
  - .packages

# FIXME: This should probably be set by Pillar or something.
hedron_obfs4_client_torrc:
  file.managed:
    - name: /etc/tor/obfs4_client.torrc
    - source: salt://hedron/obfs4/files/client.torrc
    - require:
      - cmd: go get git.torproject.org/pluggable-transports/obfs4.git/obfs4proxy

hedron_obfs4_client_tor_running:
  service.running:
    - name: tor@obfs4_client
    - watch:
      - file: /etc/tor/obfs4_client.torrc
