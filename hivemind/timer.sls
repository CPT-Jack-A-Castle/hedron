hedron_hivemind_timer_service_file:
  file.managed:
    - name: /etc/systemd/system/hivemind.service
    - contents: |
        [Unit]
        Description=Hivemind beacon
        [Service]
        Type=oneshot
        ExecStart=/usr/local/bin/hivemind beacon
        TimeoutSec=3600
        [Install]
        WantedBy=multi-user.target

hedron_hivemind_timer_timer_file:
  file.managed:
    - name: /etc/systemd/system/hivemind.timer
    - contents: |
        [Unit]
        Description=Hivemind beacon timer
        [Timer]
        OnCalendar=daily
        [Install]
        WantedBy=multi-user.target

hedron_hivemind_timer_service_running:
  service.running:
    - name: hivemind.timer
    - enable: True
    - watch:
      - file: /etc/systemd/system/hivemind.timer

hedron_hivemind_alert_timer_service_file:
  file.managed:
    - name: /etc/systemd/system/hivemind_alert.service
    - contents: |
        [Unit]
        Description=Hivemind alert
        [Service]
        Type=oneshot
        ExecStart=/usr/local/bin/hivemind send_alert_if_necessary
        TimeoutSec=60
        [Install]
        WantedBy=multi-user.target

hedron_hivemind_alert_timer_timer_file:
  file.managed:
    - name: /etc/systemd/system/hivemind_alert.timer
    - contents: |
        [Unit]
        Description=Hivemind alert timer every ten minutes
        [Timer]
        OnCalendar=*:0/10
        [Install]
        WantedBy=multi-user.target

hedron_hivemind_alert_timer_service_running:
  service.running:
    - name: hivemind_alert.timer
    - enable: True
    - watch:
      - file: /etc/systemd/system/hivemind_alert.timer
