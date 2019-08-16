include:
  - .user

# Format: https://github.com/rqlite/rqlite/blob/master/DOC/SECURITY.md#example-configuration-file
{% if 'hedron.rqlited.auth' in pillar %}
hedron_rqlite_auth:
  file.serialize:
    - name: /etc/rqlited/auth.json
    - dataset_pillar: hedron.rqlited.auth
    - mode: 0640
    - user: root
    - group: rqlite
    - formatter: json
    - makedirs: True
{% endif %}

# Lots of security issues here.
# https://github.com/systemd/systemd/issues/13333
# Mode 0600 wouldn't fix it.
hedron_rqlite_service_file:
  file.managed:
    - name: /etc/systemd/system/rqlited.service
    - contents: |
        [Unit]
        Description=rqlited replicated sqlite daemon
        [Service]
        User=rqlite
        Group=rqlite
        ExecStart=/usr/local/bin/rqlited {% if 'hedron.rqlited.options' in pillar %}{{ pillar['hedron.rqlited.options'] }}{% endif %} /var/lib/rqlited
        UMask=0077
        Restart=on-failure
        NoNewPrivileges=yes
        PrivateDevices=yes
        ProtectHome=yes
        ProtectSystem=full
        [Install]
        WantedBy=multi-user.target
    - check_cmd: systemd-analyze verify
    - tmp_ext: .service

hedron_rqlite_service_running:
  service.running:
    - name: rqlited
    - enable: True
    - watch:
      - file: /etc/systemd/system/rqlited.service
