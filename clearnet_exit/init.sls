include:
  - hedron.dhcpd
  - hedron.openvpn
  - hedron.iptables
  - hedron.tor

hedron_clearnet_exit_tor_config:
  file.managed:
    - name: /etc/tor/clearnet_exit.torrc
    - source: salt://hedron/clearnet_exit/files/clearnet_exit.torrc

hedron_clearnet_exit_tor_running:
  service.running:
    - name: tor@clearnet_exit
    - enable: True
    - watch:
      - file: /etc/tor/clearnet_exit.torrc

hedron_clearnet_exit_generate_openvpn_key:
  cmd.run:
    - name: openvpn --genkey --secret /etc/openvpn/clearnet_exit_static.key
    - creates: /etc/openvpn/clearnet_exit_static.key
    - umask: 0077

hedron_clearnet_exit_server_config:
  file.managed:
    - name: /etc/openvpn/clearnet_exit_server.conf
    - source: salt://hedron/clearnet_exit/files/server.conf.jinja
    - template: jinja
    - mode: 0400

# Possible race condition where the Tor hidden service hostname may not exist yet.
hedron_clearnet_exit_client_config:
  file.managed:
    - name: /etc/openvpn/clearnet_exit_client.conf
    - source: salt://hedron/clearnet_exit/files/client.conf.jinja
    - template: jinja
    - mode: 0400

hedron_clearnet_exit_openvpn_service_running:
  service.running:
    - name: openvpnovertor@clearnet_exit_server
    - enable: True
    - watch:
      - file: /etc/openvpn/clearnet_exit_server.conf

hedron_clearnet_exit_ip_forwarding:
  sysctl.present:
    - name: net.ipv4.ip_forward
    - value: 1

hedron_clearnet_exit_iptables:
  file.managed:
    - name: /etc/iptables.rules
    - source: salt://hedron/clearnet_exit/files/iptables.rules

# Could be a possible race condition where openvpn doesn't open the clearnetexit tap device by now.
hedron_clearnet_exit_dhcpd_config:
  file.managed:
    - name: /etc/dhcpd-clearnetexit.conf
    - source: salt://hedron/clearnet_exit/files/dhcpd.conf
    - mode: 0400

hedron_clearnet_exit_dhcpd_running:
  service.running:
    - name: dhcpd@clearnetexit
    - enable: True
