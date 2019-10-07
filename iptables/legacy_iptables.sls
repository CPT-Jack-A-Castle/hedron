# We are using the legacy iptables and need to update to iptables-nft.
# Debian Buster uses iptables-nft
# https://wiki.debian.org/iptables

# This should be Stretch safe by design.

{% for command in ['iptables', 'ip6tables', 'arptables', 'ebtables'] %}
hedron_iptables_legacy_iptables_{{ command }}:
  cmd.run:
    - name: update-alternatives --set {{ command }} /usr/sbin/{{ command }}-legacy
    - onlyif: 'update-alternatives --query {{ command }} | grep "Value: /usr/sbin/{{ command }}-nft"'
{% endfor %}
