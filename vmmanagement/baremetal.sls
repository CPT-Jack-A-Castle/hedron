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

# We setup a socket so that vmmanagement_baremetal can have a vmmanagement group and still have a socket for www-data.
hedron_vmmanagement_baremetal_socket_file:
  file.managed:
    - name: /etc/systemd/system/vmmanagement_baremetal.socket
    - contents: |
        [Unit]
        Description=VM Management Baremetal Socket
        [Socket]
        ListenStream=/run/vmmanagement_baremetal/uwsgi.sock
        SocketUser=vmmanagement
        SocketGroup=www-data
        SocketMode=0660
        [Install]
        WantedBy=sockets.target

# Unfortunately for .socket files, systemd-analyze checks for that filename.service to be running and can't find it, so fails.
# Ignoring this extra sanity step for now.
#    - check_cmd: systemd-analyze verify
#    - tmp_ext: .socket

# uwsgi socket only
hedron_vmmanagement_baremetal_service_file:
  file.managed:
    - name: /etc/systemd/system/vmmanagement_baremetal.service
    - contents: |
        [Unit]
        Description=VM Management Baremetal
        [Service]
        KillSignal=SIGINT
        UMask=0077
        Group=vmmanagement
        User=vmmanagement
        ExecStart=/usr/local/bin/uwsgi --python-path /usr/lib/python3/dist-packages --python-path /usr/local/lib/python3.5/dist-packages -L -p 5 --limit-post 131072 --master --wsgi-file /usr/local/lib/python3.5/dist-packages/vmmanagement_baremetal.py --callable __hug_wsgi__ --uwsgi-socket /run/vmmanagement_baremetal/uwsgi.sock --need-app --chmod-socket=660
        NoNewPrivileges=yes
        PrivateDevices=yes
        ProtectSystem=full
        [Install]
        WantedBy=multi-user.target
    - check_cmd: systemd-analyze verify
    - tmp_ext: .service

# Socket comes before service.
hedron_vmmanagement_baremetal_socket_running:
  service.running:
    - name: vmmanagement_baremetal.socket
    - enable: True
    - watch:
      - file: /etc/systemd/system/vmmanagement_baremetal.socket

hedron_vmmanagement_baremetal_service_running:
  service.running:
    - name: vmmanagement_baremetal.service
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
