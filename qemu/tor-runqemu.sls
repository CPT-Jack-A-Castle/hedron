# Hidden Service access to all 16 slots.

hedron_qemu_tor-runqemu_torrc:
  file.managed:
    - name: /etc/tor/runqemu.torrc
    - source: salt://hedron/qemu/files/runqemu.torrc.jinja
    - template: jinja

hedron_qemu_tor-runqemu_tor_running:
  service.running:
    - name: tor@runqemu
    - enable: True
    - watch:
      - file: /etc/tor/runqemu.torrc
