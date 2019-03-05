hedron_nginx_http_to_https_configuration_file:
  file.managed:
    - name: /etc/nginx/sites-enabled/http_to_https.conf
    - contents: |
        server {
            listen [::]:80;
            listen 80;
            server_name _;
            return 301 https://$host$request_uri;
        }

# Maybe should have a service.running here, but there are drawbacks to that.
