# FIXME BREAKSBUSTER: This is broken in Debian Buster: https://github.com/saltstack/salt/issues/51745

# Use IPv6 privacy extensions.
hedron_networking_ipv6_privacy_ipv6_private_default:
  sysctl.present:
    - name: net.ipv6.conf.default.use_tempaddr
    - value: 2

# This doesn't always apply till a reboot. I think it's a kernel bug.
hedron_networking_ipv6_privacy_ipv6_private_all:
  sysctl.present:
    - name: net.ipv6.conf.all.use_tempaddr
    - value: 2

