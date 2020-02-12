# xfonts-base is needed so you can select other font sizes in xterm.
hedron_xterm_packages:
  pkg.installed:
    - pkgs:
      - xterm
      - xfonts-base

hedron_xterm_systemd_file:
  file.managed:
    - name: /etc/systemd/system/xterm@.service
    - mode: 0644
    - source: salt://hedron/xterm/files/xterm@.service

hedron_xterm_root_systemd_file:
  file.managed:
    - name: /etc/systemd/system/xterm@root.service
    - mode: 0644
    - source: salt://hedron/xterm/files/xterm@root.service
