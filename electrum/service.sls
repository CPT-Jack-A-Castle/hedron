# FIXME: electrum should have a unix socket option and just place that unix socket under /run/electrum

# FUTURE: When we switch to systemd 235 we can use StateDirectory and possibly improve this further.
electrum_service_file:
  file.managed:
    - name: /etc/systemd/system/electrum.service
    - contents: |
        [Unit]
        Description=electrum
        After=network.target
        [Service]
        DynamicUser=yes
        RuntimeDirectory=electrum
        Environment=HOME=/run/electrum
        ExecStart=/srv/electrum/electrum -D /run/electrum daemon
        [Install]
        WantedBy=multi-user.target

electrum_service_running:
  service.running:
    - name: electrum
    - enable: True
    - watch:
      - file: /etc/systemd/system/electrum.service
