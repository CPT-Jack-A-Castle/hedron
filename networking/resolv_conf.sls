# Sets up systemd-resolved.
# systemd-resolved can be buggy alone, and/or in conjunction with other DNS servers
# locally due to SO_REUSEPORT style issues.
# It can also improve redundancy in some cases, and improve speed when used with Tor
# tremendously in some cases.

# Update: Actually, caching DNS queries when using Tor can make it less private.
# Probably better not to do this by default.

# One should think about how these settings act with tornet.
# nat mode VM will use this setting normally. A tor mode VM will have iptables
# direct such traffic to tor ultimately, and the IPs won't matter. Unless
# it's localhost. Or well, resolv.conf on the VM is localhost. If resolv.conf
# is localhost on the workstation, then user mode qemu will handle it and try
# to connect, which gets redirected or not depending on tornet iptables rules...
#
# The redirection only happens depending on the uid and/or gid of the process,
# qemu or otherwise.

{% if 'hedron_networking_resolv_conf' in grains %}
{% set resolv_conf_enable = grains['hedron_networking_resolv_conf'] %}
{% else %}
{% set resolv_conf_enable = False %}
{% endif %}

{# == and not is with jinja. #}
{% if resolv_conf_enable == True %}
# FEATURE: DNSSEC should be toggle-able.
# This is OpenDNS and 1.1.1.1 (Cloudflare)
hedron_networking_resolv_conf_systemd_conf:
  file.managed:
    - name: /etc/systemd/resolved.conf
    - mode: 0444
    - contents: |
        [Resolve]
        DNS=208.67.222.222 208.67.220.220 2620:0:ccc::2 2620:0:ccd::2 1.1.1.1 1.0.0.1 2606:4700:4700::1111 2606:4700:4700::1001
        LLMNR=no
        DNSSEC=no
        Cache=yes
        DNSStubListener=udp

hedron_networking_resolv_conf_systemd_service:
  service.running:
    - name: systemd-resolved
    - enable: True
    - watch:
      - file: /etc/systemd/resolved.conf

# attr is set to i for immutable. We don't want write for root to try and trick dhclient into not updating it.
# With the file immutable, saltstack isn't smart enough to set it to mutable before trying to edit it. So keep that in mind.
# attrs don't work with gocryptfs: https://github.com/rfjakob/gocryptfs/issues/266
# Not totally necessarily required, maybe can fight with dhclient configs until this is set.
hedron_networking_resolv_conf:
  file.managed:
    - name: /etc/resolv.conf
    - mode: 0444
    - contents: |
        nameserver 127.0.0.53
#    - attrs: i

# systemd-resolved can fail without log or error. DNS queries will show as refused. Not sure why.
# This helps mitigate that.
hedron_networking_resolv_conf_systemd_restart_if_needed:
  cmd.run:
    - name: systemctl restart systemd-resolved
    - unless: host localhost


{% endif %}
