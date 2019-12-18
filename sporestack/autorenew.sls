include:
  - hedron.sporestack
  - hedron.walkingliberty
  - .expiration_statsd

hedron_sporestack_autorenew_bip32:
  file.managed:
    - name: /var/tmp/autorenew_bip32
    - contents_pillar: hedron.walkingliberty
    - mode: 0400

hedron_sporestack_autorenew_currency:
  file.managed:
    - name: /var/tmp/autorenew_currency
    - contents_pillar: hedron.walkingliberty.currency
    - mode: 0400

hedron_sporestack_autorenew_script:
  file.managed:
    - name: /usr/local/sbin/autorenew
    - source: salt://hedron/sporestack/files/renew.sh
    - mode: 0500

hedron_sporestack_autorenew_service:
  file.managed:
    - name: /etc/systemd/system/autorenew.service
    - replace: False
    - contents: |
        [Unit]
        Description=Renew SporeStack server
        [Service]
        Type=oneshot
        ExecStart=/usr/local/sbin/autorenew
        [Install]
        WantedBy=multi-user.target
    - check_cmd: systemd-analyze verify
    - tmp_ext: .service

# script is set to renew for 1 day, so run daily.
hedron_sporestack_autorenew_service_timer:
  file.managed:
    - name: /etc/systemd/system/autorenew.timer
    - replace: False
    - contents: |
        [Unit]
        Description=SporeStack renewal timer
        [Timer]
        OnCalendar=daily
        [Install]
        WantedBy=multi-user.target
    - check_cmd: systemd-analyze verify
    - tmp_ext: .timer

hedron_sporestack_autorenew_service_timer_running:
  service.running:
    - name: autorenew.timer
    - enable: True

