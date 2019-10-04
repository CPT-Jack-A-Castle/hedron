# Python sites module breaks with DynamicUser. Need -S if cli, or --no-site and some others if uwsgi.

include:
  - hedron.uwsgi3
  - .package
  - hedron.rqlite.service

# Port 3000, localhost, also uwsgi socket
settlers_of_cryptotan_service_file:
  file.managed:
    - name: /etc/systemd/system/settlers_of_cryptotan.service
    - contents: |
        [Unit]
        Description=Settlers of Cryptotan
        [Service]
        KillSignal=SIGINT
        RuntimeDirectory=settlers_of_cryptotan
        DynamicUser=yes
        Group=www-data
        ExecStart=/usr/local/bin/uwsgi --python-path /usr/lib/python3/dist-packages --python-path {{ grains['hedron.python.dist.path'] }} --no-site -L -p 5 --limit-post 131072 --master --wsgi-file {{ grains['hedron.python.dist.path'] }}/settlers_of_cryptotan.py --callable __hug_wsgi__ --uwsgi-socket /run/settlers_of_cryptotan/uwsgi.sock --need-app --chmod-socket=660 --http-socket [::1]:3000 --http-socket 127.0.0.1:3000
        [Install]
        WantedBy=multi-user.target


settlers_of_cryptotan_service_running:
  service.running:
    - name: settlers_of_cryptotan
    - enable: True
    - watch:
      - file: {{ grains['hedron.python.dist.path'] }}/settlers_of_cryptotan.py
      - file: /etc/systemd/system/settlers_of_cryptotan.service
