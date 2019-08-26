# liboping0 is for collectd's ping plugin, currently out
hedron_monitorme_collectd_installed:
  pkg.installed:
    - pkgs:
      - collectd

hedron_monitorme_collectd_configuration_file:
  file.managed:
    - name: /etc/collectd/collectd.conf
    - source: salt://hedron/monitorme/files/collectd.conf.jinja
    - template: jinja
    - check_cmd: collectd -t -C

hedron_monitorme_collectd_service_file:
  file.managed:
    - name: /lib/systemd/system/collectd.service
    - source: salt://hedron/monitorme/files/collectd.service
    - check_cmd: systemd-analyze verify
    - tmp_ext: .service

hedron_monitorme_collectd_collectd_kill_initd:
  cmd.run:
    - name: systemctl stop collectd; /etc/init.d/collectd stop; rm /etc/init.d/collectd
    - onlyif: test -f /etc/init.d/collectd

hedron_monitorme_collectd_service:
  service.running:
    - name: collectd
    - enable: True
    - watch:
      - file: /etc/collectd/collectd.conf
      - file: /lib/systemd/system/collectd.service
