hedron_nginx_status_configuration_file:
  file.managed:
    - name: /etc/nginx/sites-enabled/status.conf
    - source: salt://hedron/nginx/files/status.nginx.conf
