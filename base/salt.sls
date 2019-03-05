hedron_base_salt_minion_config:
  file.managed:
    - name: /etc/salt/minion
    - source:
      - salt://hedron_base/files/minion.jinja
      - salt://hedron/base/files/minion.jinja
    - template: jinja
    - makedirs: True

# We use salt-call --local or salt-ssh instead of the salt minion.
hedron_base_salt_kill_saltminion:
  service.dead:
    - name: salt-minion
    - enable: False
