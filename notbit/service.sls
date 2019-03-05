# If we let notbit log to stdout, it will try to open /dev/stdout
# and break under systemd. Instead, log to /run/notbit/log

# The execstop sigkill is to make sure it doesn't overwrite the keys.dat
# if we override it. When stopping normally, it writes out the keys.
# This whole set of hacks is extremely ugly.
# Restart=on-failure because this is buggy.
# Also because of https://github.com/bpeel/notbit/issues/15
# which happens sort of frequently.
# MemoryMax=100M because memory use can get out of hand quickly with it.
# LimitCPU=7200 because it can hit 100% CPU and be useless.
hedron_notbit_service_file:
  file.managed:
    - name: /etc/systemd/system/notbit.service
    - contents: |
        [Unit]
        Description=notbit bitmessage daemon
        After=network.target
        [Service]
        User=notbit
        Group=notbit
        UMask=0007
        RuntimeDirectory=notbit
        Environment=HOME=/var/lib/notbit XDG_RUNTIME_DIR=/run/notbit
        ExecStart=/usr/local/bin/notbit -l /run/notbit/log -D /var/lib/notbit -m /run/notbit/.maildir
        ExecStop=/bin/kill -s KILL $MAINPID
        Restart=on-failure
        RestartSec=5
        MemoryMax=100M
        OOMScoreAdjust=900
        LimitCPU=7200
        [Install]
        WantedBy=multi-user.target

hedron_notbit_service_running:
  service.running:
    - name: notbit
    - enable: True
    - watch:
      - file: /etc/systemd/system/notbit.service

# Generate "system" address if we don't have it already
# FIXME: Sleep is hacky, to make sure daemon is alive
# Second sleep is in case there's a delay in creating keys.dat
hedron_notbit_service_generate_key:
  cmd.run:
    - name: sleep 3; notbit-keygen-system; sleep 3
    - creates: /var/lib/notbit/keys.dat

# notbit insists on keys.dat being chmod 0600 when we need 0660
# We should fix those permissions in notbit, itself.
hedron_notbit_service_key_permissions:
  file.managed:
    - name: /var/lib/notbit/keys.dat
    - mode: 0660

hedron_notbit_service_restarter_file:
  file.managed:
    - name: /etc/systemd/system/notbit-restarter.service
    - contents: |
        [Unit]
        Description=notbit service restarter
        [Service]
        Type=oneshot
        ExecStart=/bin/systemctl restart notbit.service

hedron_notbit_service_path_file:
  file.managed:
    - name: /etc/systemd/system/notbit-restarter.path
    - contents: |
        [Path]
        PathChanged=/var/lib/notbit/keys.dat
        [Install]
        WantedBy=multi-user.target

hedron_notbit_service_path_running:
  service.running:
    - name: notbit-restarter.path
    - enable: True
