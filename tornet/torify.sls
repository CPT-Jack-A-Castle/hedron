# This mode only torifies the slots and a "torify" user.
# Does not torify everything except notor (basically) like the traditional tornet.
# Big issue here, DO NOT USE 127.0.0.1 AS YOUR RESOLVER!
# VM DNS traffic will exit and not through Tor if you do, at least possibly.
# Needs testing.

include:
  - .torify_user
  - .main

hedron_tornet_torify_iptables_rules:
  file.managed:
    - name: /etc/iptables.rules
    - source: salt://hedron/tornet/files/torify-iptables.rules.jinja
    - template: jinja
