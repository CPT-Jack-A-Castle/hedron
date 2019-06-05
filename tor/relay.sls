hedron_tor_relay_config:
  file.managed:
    - name: /etc/tor/relay.torrc
    - source: salt://hedron/tor/files/relay.torrc.jinja
    - template: jinja

hedron_tor_relay_service_file:
  file.managed:
    - name: /etc/systemd/system/tor_relay.service
    - contents: |
        [Unit]
        Description=Tor relay
        After=network.target
        [Service]
        NoNewPrivileges=true
        DynamicUser=yes
        # Current systemd is broken with DynamicUser / named Group combinations
        # Should be equivalent.
        Group=67
        UMask=0077
        RuntimeDirectory=tor_relay
        ExecStart=/usr/sbin/tor -f /etc/tor/relay.torrc
        OOMScoreAdjust=100
        Restart=on-failure
        RestartSec=5

hedron_tor_relay_service_running:
  service.running:
    - name: tor_relay
    - enable: True
    - watch:
      - file: /etc/systemd/system/tor_relay.service
      - file: /etc/tor/relay.torrc
