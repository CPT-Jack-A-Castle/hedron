# We enable this but don't start it, so it runs only after a reboot.

hedron_hivemind_uptime_reset_service_file:
  file.managed:
    - name: /etc/systemd/system/hivemind_uptime_reset.service
    - contents: |
        [Unit]
        Description=Hivemind uptime reset notitifcation
        After=notbit.service
        [Service]
        Type=oneshot
        ExecStart=/usr/local/bin/hivemind uptime_reset
        [Install]
        WantedBy=multi-user.target

hedron_hivemind_uptime_reset_service_enabled:
  service.enabled:
    - name: hivemind_uptime_reset
