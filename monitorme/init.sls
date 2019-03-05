# liboping0 is for collectd's ping plugin
hedron_monitorme_packages:
  pkg.installed:
    - pkgs:
      - collectd
      - liboping0

hedron_monitorme_collectd_configuration_file:
  file.managed:
    - name: /etc/collectd/collectd.conf
    - source: salt://hedron/monitorme/files/collectd.conf.jinja
    - template: jinja

hedron_monitorme_collectd_service:
  service.running:
    - name: collectd
    - enable: True
    - watch:
      - file: /etc/collectd/collectd.conf
