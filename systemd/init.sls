# Configures base level systemd configuration

hedron_systemd_journald_configuration:
  file.managed:
    - name: /etc/systemd/journald.conf
    - source: salt://hedron/systemd/files/journald.conf

hedron_systemd_journald_service:
  service.running:
    - name: systemd-journald
    - enable: True
    - watch:
        - file: /etc/systemd/journald.conf
