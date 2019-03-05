include:
  - .base

hedron_namesiren_update_nameservers_configuration:
  file.managed:
    - name: /etc/update_nameservers.cfg
    - mode: 0400
    - template: jinja
    - source: salt://hedron/namesilo/files/update_nameservers.cfg.jinja

hedron_namesilo_update_nameservers:
  cmd.script:
    - source: salt://hedron/namesilo/files/update_nameservers.sh
    - creates: /var/tmp/updated_nameservers
