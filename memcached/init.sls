# memcached service comes up by default and isn't too harmful, so won't split this into package/service.sls for now.

hedron_memcached_package:
  pkg.installed:
    - name: memcached

hedron_memcached_configuration:
  file.managed:
    - name: /etc/memcached.conf
    - source: salt://hedron/memcached/files/memcached.conf

hedron_memcached_service:
  service.running:
    - name: memcached
    - enable: True
    - watch:
      - file: /etc/memcached.conf
