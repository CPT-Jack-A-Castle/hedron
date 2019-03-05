# FUTURE: When we switch to systemd 235 we can use StateDirectory and possibly improve this further.
electron-cash_service_file:
  file.managed:
    - name: /etc/systemd/system/electron-cash.service
    - contents: |
        [Unit]
        Description=electron-cash
        After=network.target
        [Service]
        DynamicUser=yes
        RuntimeDirectory=electron-cash
        Environment=HOME=/run/electron-cash
        ExecStart=/srv/electron-cash/electron-cash -D /run/electron-cash daemon
        [Install]
        WantedBy=multi-user.target

electron-cash_service_running:
  service.running:
    - name: electron-cash
    - enable: True
    - watch:
      - file: /etc/systemd/system/electron-cash.service
