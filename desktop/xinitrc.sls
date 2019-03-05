hedron_desktop_xinitrc_desired_resolution:
  file.managed:
    - name: /etc/X11/desired_resolution
    - contents_pillar: hedron.desktop.resolution
    - replace: False
    - mode: 0400

hedron_desktop_xinitrc:
  file.managed:
    - name: /etc/X11/xinit/xinitrc
    - mode: 0500
    - source: salt://hedron/desktop/files/xinitrc.sh
    - makedirs: True
