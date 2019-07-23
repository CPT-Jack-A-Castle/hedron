include:
  - hedron.nginx

# FIXME: Designed for ssh port forwarding to get to the dashboard
# Example: ssh -L 8079:127.0.0.1:8079 -L 8081:127.0.0.1:8081 root@foo.onion

hedron_monitoring_giraffee_nginx_config:
  file.managed:
    - name: /etc/nginx/sites-enabled/monitoring.conf
    - source: salt://hedron/monitoring/files/nginx.conf.jinja
    - template: jinja

hedron_monitoring_giraffee_web_root:
  file.directory:
    - name: /var/www/monitoring
    - group: www-data
    - mode: 0750

hedron_monitoring_giraffee_nginx_service:
  service.running:
    - name: nginx
    - enable: True
    - watch:
      - file: /etc/nginx/sites-enabled/monitoring.conf

hedron_monitoring_giraffee_fetch:
  file.managed:
    - name: /srv/salt/dist/giraffe.tar.gz
    - source: https://github.com/kenhub/giraffe/archive/1.3.1.tar.gz
    - source_hash: 8c24daa1828f9dba919bd393e77b8814de9ee10de8490d84d9305a39bf077655
    - makedirs: True

hedron_monitoring_giraffee_extracted:
  cmd.run:
    - name: tar -xzf /srv/salt/dist/giraffe.tar.gz -C /var/www/monitoring --strip-components=1
    - creates: /var/www/monitoring/index.html

hedron_monitoring_giraffee_settings:
  file.managed:
    - name: /var/www/monitoring/dashboards.js
    - source: salt://hedron/monitoring/files/dashboards.js.jinja
    - template: jinja
