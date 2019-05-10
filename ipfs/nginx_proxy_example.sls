include:
  - hedron.ipfs
  - hedron.nginx

hedron_ipfs_nginx_proxy_example_config:
  file.managed:
    - name: /etc/nginx/sites-enabled/ipfs_proxy_example.conf
    - source: salt://hedron/ipfs/files/ipfs_proxy_example.nginx.conf.jinja
    - template: jinja

hedron_ipfs_nginx_proxy_example_service:
  service.running:
    - name: nginx
    - enable: True
    - watch:
      - file: /etc/nginx/sites-enabled/ipfs_proxy_example.conf
