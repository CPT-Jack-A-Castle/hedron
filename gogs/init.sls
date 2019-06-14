hedron_gogs_archive:
  file.managed:
    - name: /srv/salt/dist/gogs.tar.gz
    - source:
      - salt://dist/gogs.tar.gz
      - https://dl.gogs.io/0.11.86/gogs_0.11.86_linux_amd64.tar.gz
    - source_hash: 01432f903e7e91aa54f7b78faf1167462da0e7b26c7f1055247a76a814688bfc
    - makedirs: True

hedron_gogs_directory:
  file.directory:
    - name: /usr/local/gogs

# Directory in tar is just "gogs"
hedron_gogs_extract:
  cmd.run:
    - name: tar --strip-components=1 --no-same-owner -xzf /srv/salt/dist/gogs.tar.gz -C /usr/local/gogs
    - creates: /usr/local/gogs/gogs

hedron_gogs_group:
  group.present:
    - name: gogs
    - gid: 941

hedron_gogs_user:
  user.present:
    - name: gogs
    - uid: 941
    - gid: 941
    - home: /usr/local/gogs/custom
    - createhome: False
    - shell: /bin/false

# makedirs: True doesn't seem to set permissions?
hedron_gogs_custom_directory:
  file.directory:
    - name: /usr/local/gogs/custom
    - user: gogs
    - group: gogs
    - mode: 0750

hedron_gogs_custom_conf_directory:
  file.directory:
    - name: /usr/local/gogs/custom/conf
    - user: gogs
    - group: gogs

hedron_gogs_data_directory:
  file.directory:
    - name: /usr/local/gogs/data
    - user: gogs
    - group: gogs
    - mode: 0750

hedron_gogs_configuration:
  file.managed:
    - name: /usr/local/gogs/custom/conf/app.ini
    - source:
      - salt://gogs/files/app.ini
      - salt://hedron/gogs/files/app.ini
    - user: gogs
    - group: gogs
    - replace: False

hedron_gogs_service_file:
  file.managed:
    - name: /etc/systemd/system/gogs.service
    - contents: |
        [Unit]
        Description=gogs
        After=network.target
        [Service]
        LimitMEMLOCK=infinity
        LimitNOFILE=65535
        User=gogs
        Group=gogs
        UMask=0077
        ExecStart=/usr/local/gogs/gogs web
        WorkingDirectory=/usr/local/gogs
        NoNewPrivileges=true
        Restart=on-failure
        [Install]
        WantedBy=multi-user.target

hedron_gogs_service_running:
  service.running:
    - name: gogs
    - enable: True
    - watch:
      - file: /etc/systemd/system/gogs.service

# Instructions:
# Browse to service.
# Set SSH Port field empty.
# Configure administrator login.
# Configure Applicaiton URL.
# Install.
# Backup /usr/local/gogs/custom and /usr/local/gogs/data regularly.
