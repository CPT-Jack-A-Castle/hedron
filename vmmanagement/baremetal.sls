include:
  - hedron.uwsgi3
  - hedron.nginx

hedron_vmmanagement_baremetal_ssh_library:
  file.managed:
    - name: /usr/local/lib/python3.5/dist-packages/vmmanagement_client_ssh.py
    - source: salt://hedron/vmmanagement/files/vmmanagement_client_ssh.py
    - mode: 0644

# Python sites module breaks with DynamicUser. Need -S if cli, or --no-site and some others if uwsgi.
hedron_vmmanagement_baremetal_library:
  file.managed:
    - name: /usr/local/lib/python3.5/dist-packages/vmmanagement_baremetal.py
    - source: salt://hedron/vmmanagement/files/vmmanagement_baremetal.py
    - mode: 0644

# uwsgi socket only
# HOME is to unbreak site module.
hedron_vmmanagement_baremetal_service_file:
  file.managed:
    - name: /etc/systemd/system/vmmanagement_baremetal.service
    - contents: |
        [Unit]
        Description=VM Management Baremetal
        [Service]
        KillSignal=SIGINT
        RuntimeDirectory=vmmanagement_baremetal
        Group=www-data
        Environment=HOME=/
        ExecStart=/usr/local/bin/uwsgi --python-path /usr/lib/python3/dist-packages --python-path /usr/local/lib/python3.5/dist-packages -L -p 5 --limit-post 131072 --master --wsgi-file /usr/local/lib/python3.5/dist-packages/vmmanagement_baremetal.py --callable __hug_wsgi__ --uwsgi-socket /run/vmmanagement_baremetal/uwsgi.sock --need-app --chmod-socket=660
        DynamicUser=yes
        NoNewPrivileges=yes
        PrivateDevices=yes
        ProtectHome=yes
        ProtectSystem=strict
        [Install]
        WantedBy=multi-user.target
    - check_cmd: systemd-analyze verify
    - tmp_ext: .service

hedron_vmmanagement_baremetal_service_running:
  service.running:
    - name: vmmanagement_baremetal
    - enable: True
    - watch:
      - file: /usr/local/lib/python3.5/dist-packages/vmmanagement_baremetal.py
      - file: /etc/systemd/system/vmmanagement_baremetal.service

hedron_vmmanagement_baremetal_nginx_configuration:
  file.managed:
    - name: /etc/nginx/sites-enabled/vmmanagement_baremetal.conf
    - source: salt://hedron/vmmanagement/files/vmmanagement_baremetal.nginx.conf

hedron_vmmanagement_baremetal_nginx_service:
  service.running:
    - name: nginx
    - enable: True
    - reload: True
    - watch:
      - file: /etc/nginx/sites-enabled/vmmanagement_baremetal.conf
