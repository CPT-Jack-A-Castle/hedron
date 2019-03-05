# FIXME: This only works if the tor state has already been called.

hedron_tor_client_config:
  file.managed:
    - name: /etc/tor/client.torrc
    - source: salt://hedron/tor/files/client.torrc.jinja
    - template: jinja

hedron_tor_client_service_file:
  file.managed:
    - name: /etc/systemd/system/tor_client.service
    - contents: |
        [Unit]
        Description=Tor client with socks port 9050
        After=network.target
        [Service]
        DynamicUser=yes
        # Fails with "invalid multi-byte"
        #Group=debian-tor
        # Should be equivalent.
        Group=67
        UMask=0077
        RuntimeDirectory=tor_client
        ExecStart=/usr/sbin/tor -f /etc/tor/client.torrc
        [Install]
        WantedBy=multi-user.target

hedron_tor_client_service_running:
  service.running:
    - name: tor_client
    - enable: True
    - watch:
      - file: /etc/systemd/system/tor_client.service
