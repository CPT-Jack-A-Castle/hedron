{% if 'hedron.ipfs.profile' in pillar %}
{% set ipfs_profile = pillar['hedron.ipfs.profile'] %}
{% else %}
{% set ipfs_profile = 'server,lowpower' %}
{% endif %}

hedron_ipfs_service_init:
  cmd.run:
    - name: ipfs init --profile {{ ipfs_profile }}
    - runas: ipfs
    - creates: /srv/ipfs/.ipfs

hedron_ipfs_service_init_verify:
  file.exists:
    - name: /srv/ipfs/.ipfs

hedron_ipfs_service_file:
  file.managed:
    - name: /etc/systemd/system/ipfs.service
    - contents: |
        [Unit]
        Description=IPFS
        After=network.target
        [Service]
        User=ipfs
        Group=ipfs
        Environment=HOME=/srv/ipfs
        ExecStart=/usr/bin/ipfs daemon
        ProtectSystem=strict
        ReadWritePaths=/srv/ipfs
        NoNewPrivileges=true
        Restart=on-failure
        OOMScoreAdjust=800
        [Install]
        WantedBy=multi-user.target

hedron_ipfs_service_running:
  service.running:
    - name: ipfs
    - enable: True
    - watch:
      - file: /etc/systemd/system/ipfs.service
