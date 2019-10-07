include:
  - .legacy_iptables

# FIXME: We should move to scripts that act for both iptables and ip6tables. Too much redunancy.
# Also, instead of flush on stop should revert to default allow-all rules... probably?

hedron_iptables_service_file:
  file.managed:
    - name: /etc/systemd/system/iptables.service
    - source: salt://hedron/iptables/files/iptables.service

hedron_iptables_ipv6_service_file:
  file.managed:
    - name: /etc/systemd/system/ip6tables.service
    - source: salt://hedron/iptables/files/ip6tables.service

hedron_iptables_stub_file:
  file.managed:
    - name: /etc/iptables.rules
    - contents: '# Stub'
    - replace: False

hedron_iptables_service_running:
  service.running:
    - name: iptables
    - enable: True
    - watch:
      - file: /etc/iptables.rules

# Both use the same rules file.
hedron_iptables_ipv6_service_running:
  service.running:
    - name: ip6tables
    - enable: True
    - watch:
      - file: /etc/iptables.rules
