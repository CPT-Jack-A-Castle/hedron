# Torifies all traffic except a small whitelist.

include:
  - .notor_user
  - .main

hedron_tornet_iptables_rules:
  file.managed:
    - name: /etc/iptables.rules
    - source: salt://hedron/tornet/files/iptables.rules.jinja
    - template: jinja
