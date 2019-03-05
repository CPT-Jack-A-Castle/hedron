hedron_nginx_configuration_purge_default:
  file.absent:
    - name: /etc/nginx/sites-enabled/default

# Undecided about taking this out... it's partly a hack to make tests pass.
hedron_nginx_configuration_purge_nginx_echo_module:
  file.absent:
    - name: /etc/nginx/modules-enabled/50-mod-http-echo.conf

# https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html
# 4096 takes forever, even 2048 takes a while.
# 2048 is hopefully enough for now.
hedron_nginx_configuration_dhparam:
  cmd.run:
    - name: openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
    - creates: /etc/ssl/certs/dhparam.pem

hedron_nginx_configuration_nginx_conf:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://hedron/nginx/files/nginx.conf

hedron_nginx_configuration_www_to_non_www:
  file.managed:
    - name: /etc/nginx/snippets/www_to_non_www.conf
    - source: salt://hedron/nginx/files/www_to_non_www.nginx.conf
