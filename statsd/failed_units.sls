hedron_statsd_failed_units_script:
  file.managed:
    - name: /usr/local/bin/statsd-failed_units
    - source: salt://hedron/statsd/files/failed_units.sh
    - mode: 0755

hedron_statsd_failed_units_service_file:
  file.managed:
    - name: /etc/systemd/system/statsd-failed_units.service
    - contents: |
        [Unit]
        Description=Uptime statsd reporting service
        [Service]
        Type=oneshot
        ExecStart=/usr/local/bin/statsd-failed_units
        [Install]
        WantedBy=multi-user.target
    - check_cmd: systemd-analyze verify
    - tmp_ext: .service

hedron_statsd_failed_units_timer_file:
  file.managed:
    - name: /etc/systemd/system/statsd-failed_units.timer
    - contents: |
        [Unit]
        Description=Uptime statsd reporting timer
        [Timer]
        OnCalendar=minutely
        [Install]
        WantedBy=multi-user.target
    - check_cmd: systemd-analyze verify
    - tmp_ext: .timer

hedron_statsd_failed_units_timer_running:
  service.running:
    - name: statsd-failed_units.timer
    - enable: True

