hedron_flaskbb_service_file:
  file.managed:
    - name: /etc/systemd/system/flaskbb.service
    - contents: |
        [Unit]
        Description=flaskbb
        After=network.target
        [Service]
        User=flaskbb
        Group=flaskbb
        UMask=0077
        ExecStart=/usr/local/bin/flaskbb run
        WorkingDirectory=/srv/flaskbb
        [Install]
        WantedBy=multi-user.target

hedron_flaskbb_service_running:
  service.running:
    - name: flaskbb
    - enable: True
