include:
  - hedron.dhcpd

hedron_qemu_primary_bridge_netdev:
  file.managed:
    - name: /etc/systemd/network/primary.netdev
    - contents: |
        [NetDev]
        Name=primary
        Kind=bridge

# Without this, link state won't be set to up
hedron_qemu_primary_bridge_network:
  file.managed:
    - name: /etc/systemd/network/primary.network
    - source: salt://hedron/qemu/files/primary.network.jinja
    - template: jinja

hedron_qemu_primary_bridge_network_systemd:
  service.running:
    - name: systemd-networkd
    - enable: True
    - watch:
      - file: /etc/systemd/network/*

# FIXME: This is only needed for native ipv6 VMs. Could cause harm for tor? May want iptables lockdown of forwarding.

hedron_qemu_primary_bridge_ndp_proxy:
  sysctl.present:
    - name: net.ipv6.conf.all.proxy_ndp
    - value: 1

# accept_ra must be 2 for it to stil accept router advertisements while forwarding
hedron_qemu_primary_bridge_ipv6_accept_ra_default:
  sysctl.present:
    - name: net.ipv6.conf.default.accept_ra
    - value: 2

{% if 'eth0' in grains['ip_interfaces'] %}

# Doing it on all/default seems necessary here
# All doesn't work?? trying eth0
# Have to force the interface :-/
hedron_qemu_primary_bridge_ipv6_accept_ra_eth0:
  sysctl.present:
    - name: net.ipv6.conf.eth0.accept_ra
    - value: 2

{% endif %}

# Tor IPv6 breaks without this...
{% if 'wlan0' in grains['ip_interfaces'] %}

hedron_qemu_primary_bridge_ipv6_accept_ra_wlan0:
  sysctl.present:
    - name: net.ipv6.conf.wlan0.accept_ra
    - value: 2

{% endif %}

hedron_qemu_primary_bridge_ipv6_forwarding:
  sysctl.present:
    - name: net.ipv6.conf.all.forwarding
    - value: 1

{% if 'hedron_vmmanagement_ipv4_host_address_with_cidr' in grains %}
hedron_qemu_primary_bridge_dhcpd_conf_head:
  file.managed:
    - name: /etc/dhcpd-primary.conf.head
    - source: salt://hedron/qemu/files/dhcpd-primary.conf.head.jinja
    - template: jinja

# We had a bug where we were making this file 666. Fix that.
# Should be able to get rid of this state at some point.
hedron_qemu_primary_bridge_dhcpd_conf_permissions:
  file.managed:
    - name: /etc/dhcpd-primary.conf
    - mode: 0600
    - create: False

hedron_qemu_primary_bridge_ip4_forwarding:
  sysctl.present:
    - name: net.ipv4.conf.all.forwarding
    - value: 1

hedron_qemu_primary_bridge_ip4_proxy_arp:
  sysctl.present:
    - name: net.ipv4.conf.all.proxy_arp
    - value: 1

# Enable only, start will happen by vmmanagement-interface?
hedron_qemu_primary_bridge_dhcpd_service_enabled:
  service.enabled:
    - name: dhcpd@primary
{% endif %}
