include:
  - hedron.tor
  - hedron.openvpn

# First copy /etc/openvpn/clearnet_exit_client.conf to the machine you want to run it on. Then run this state.

hedron_clearnet_client_openvpn_service:
  service.running:
    - name: openvpnovertor@clearnet_exit_client
    - enable: True
