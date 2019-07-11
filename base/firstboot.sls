# /usr/local/bin/salt-call if using pip installed salt

hedron_base_firstboot_service_file:
  file.managed:
    - name: /etc/systemd/system/firstboot.service
    - contents: |
        [Unit]
        Description=Salt Highstate Bootstrap
        After=network.target
        [Service]
        Environment=HOME=/root
        ExecStart=/usr/bin/salt-call -l info --local state.highstate failhard=True --retcode-passthrough
        StandardOutput=journal+console
        Restart=on-failure
        RestartSec=30
        [Install]
        WantedBy=multi-user.target
