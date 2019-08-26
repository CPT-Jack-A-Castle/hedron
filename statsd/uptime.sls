hedron_statsd_uptime_script:
  file.managed:
    - name: /usr/local/bin/statsd-uptime
    - source: salt://hedron/statsd/files/uptime.sh
    - mode: 0755

hedron_statsd_uptime_service_file:
  file.managed:
    - name: /etc/systemd/system/statsd-uptime.service
    - contents: |
        [Unit]
        Description=Uptime statsd reporting service
        [Service]
        Type=oneshot
        ExecStart=/usr/local/bin/statsd-uptime
        DynamicUser=yes
        ProtectSystem=strict
        NoNewPrivileges=yes
        [Install]
        WantedBy=multi-user.target
    - check_cmd: systemd-analyze verify
    - tmp_ext: .service

hedron_statsd_uptime_timer_file:
  file.managed:
    - name: /etc/systemd/system/statsd-uptime.timer
    - contents: |
        [Unit]
        Description=Uptime statsd reporting timer
        [Timer]
        OnCalendar=minutely
        [Install]
        WantedBy=multi-user.target
    - check_cmd: systemd-analyze verify
    - tmp_ext: .timer

hedron_statsd_uptime_timer_running:
  service.running:
    - name: statsd-uptime.timer
    - enable: True

