hedron_dhcpd_package:
  pkg.installed:
    - name: isc-dhcp-server


hedron_dhcpd_kill_default_service:
  service.dead:
    - name: isc-dhcpd-server
    - enable: False

hedron_dhcpd_reset_failed_service:
  cmd.run:
    - name: systemctl reset-failed isc-dhcp-server
    - onlyif: systemctl is-failed isc-dhcp-server

# FIXME: This probably has a race condition with the openvpn@ service not creating the interface before this runs.
# So a reboot will probably kill this.
hedron_dhcpd_service_file:
  file.managed:
    - name: /etc/systemd/system/dhcpd@.service
    - source: salt://hedron/dhcpd/files/dhcpd@.service
