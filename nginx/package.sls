# Debian's run services on package install policy is awful. This is a workaround for all the breakage that causes.
# Have to be careful here else we might disable the nginx service on a system that we want it running on.

hedron_nginx_package_installed:
  cmd.run:
    - name: apt-get install -y nginx-light; rm /etc/init/nginx.conf /etc/init.d/nginx; systemctl disable nginx; systemctl stop nginx
    - creates: /usr/sbin/nginx
