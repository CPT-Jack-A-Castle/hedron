# We try to call this towards the end for a few reasons.

# Networking-related base settings.

# Also, we can use systemd's built in dhcp instead.
# FIXME: These settings are not loaded in on the first boot, only after restarts.
# restarting networking seems to break networking till a reboot.
hedron_base_networking_dhclient_conf:
  file.managed:
    - name: /etc/dhcp/dhclient.conf
    - source: salt://hedron/base/files/dhclient.conf

hedron_base_networking_systemd:
  service.running:
    - name: systemd-networkd
    - enable: True
