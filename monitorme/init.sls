# liboping0 is for collectd's ping plugin, currently out
hedron_monitorme_packages:
  pkg.installed:
    - pkgs:
      - collectd

hedron_monitorme_collectd_configuration_file:
  file.managed:
    - name: /etc/collectd/collectd.conf
    - source: salt://hedron/monitorme/files/collectd.conf.jinja
    - template: jinja
    - check_cmd: collectd -t -C

monitorme_service_file:
  file.managed:
    - name: /etc/systemd/system/collectd.service
    - source: salt://hedron/monitorme/files/collectd.service
    - check_cmd: systemd-analyze verify
    - tmp_ext: .service

monitorme_kill_collectd_initd:
  cmd.run:
    - name: systemctl stop collectd; /etc/init.d/collectd stop; rm /etc/init.d/collectd
    - onlyif: test -f /etc/init.d/collectd

monitorme_kill_collectd_old_service_file:
  file.absent:
    - name: /lib/systemd/system/collectd.service

hedron_monitorme_collectd_service:
  service.running:
    - name: collectd
    - enable: True
    - watch:
      - file: /etc/collectd/collectd.conf
      - file: /etc/systemd/system/collectd.service
