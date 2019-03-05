# We setup the service file but don't enable any by default.

# Down the road should have a pillar of endpoints to monitor and turn those on.

hedron_httpmonitor_service_file:
  file.managed:
    - name: /etc/systemd/system/httpmonitor@.service
    - contents: |
        [Unit]
        Description=httpmonitor for %I
        [Service]
        Type=oneshot
        TimeoutSec=300
        ExecStart=/usr/local/bin/httpmonitor %I
        [Install]
        WantedBy=multi-user.target

hedron_httpmonitor_service_timer:
  file.managed:
    - name: /etc/systemd/system/httpmonitor@.timer
    - contents: |
        [Unit]
        Description=Monitor %I every minute
        [Timer]
        OnCalendar=*:0/10
        [Install]
        WantedBy=multi-user.target
