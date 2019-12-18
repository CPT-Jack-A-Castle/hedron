# expiration statsd info

include:
  - .liferemaining

hedron_sporestack_expiration_statsd_script:
  file.managed:
    - name: /usr/local/sbin/sporestack-expiration-statsd
    - mode: 0755
    - source: salt://hedron/sporestack/files/expiration-statsd.sh

hedron_sporestack_expiration_statsd_service:
  file.managed:
    - name: /etc/systemd/system/sporestack_expiration_statsd.service
    - replace: False
    - contents: |
        [Unit]
        Description=SporeStack expiration statsd reporting service
        [Service]
        Type=oneshot
        ExecStart=/usr/local/sbin/sporestack-expiration-statsd
        [Install]
        WantedBy=multi-user.target
    - check_cmd: systemd-analyze verify
    - tmp_ext: .service

hedron_sporestack_expiration_statsd_service_timer:
  file.managed:
    - name: /etc/systemd/system/sporestack_expiration_statsd.timer
    - replace: False
    - contents: |
        [Unit]
        Description=SporeStack expiration statsd timer
        [Timer]
        OnCalendar=minutely
        [Install]
        WantedBy=multi-user.target
    - check_cmd: systemd-analyze verify
    - tmp_ext: .timer

hedron_sporestack_expiration_statsd_service_timer_running:
  service.running:
    - name: sporestack_expiration_statsd.timer
    - enable: True

