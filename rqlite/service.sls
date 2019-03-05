# FIXME: For now, run as root. Yuck.

# FUTURE: When we switch to systemd 235 we can use StateDirectory and possibly improve this further.
hedron_rqlite_service_file:
  file.managed:
    - name: /etc/systemd/system/rqlite.service
    - contents: |
        [Unit]
        Description=rqlite
        [Service]
        ExecStart=/usr/local/bin/rqlited /var/lib/rqlited
        UMask=0077
        Restart=on-failure
        [Install]
        WantedBy=multi-user.target

hedron_rqlite_service_running:
  service.running:
    - name: rqlite
    - enable: True
    - watch:
      - file: /etc/systemd/system/rqlite.service
