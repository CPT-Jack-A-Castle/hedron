hedron_xorg_packages:
  pkg.installed:
    - pkgs:
      - xorg
      - sct

hedron_xorg_startx_systemd_file:
  file.managed:
    - name: /etc/systemd/system/startx.service
    - source: salt://hedron/xorg/files/startx.service

hedron_xorg_startx_running:
  service.running:
    - name: startx
    - enable: True
