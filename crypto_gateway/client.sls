include:
  - hedron.openvpn

# Usage:
# 1. Copy /etc/openvpn/crypto_gateway_client.conf to the machine you want to run it on.
# 2. Edit the file and update the remote line to point to the endpoint of the server.
# 3. Finally, run this state: state.sls hedron.crypto_gateway.client

# This one is super weird. If tornet is on a VM you want to use openvpn@ and not openvpnovertor@.
# Although why mix tornet and this on a VM?
# And this should always be on a VM. Unless you want to not change the default route and just make
# a tun device. Then it should be openvpnovertor@, if on a host that has tornet set.

hedron_clearnet_client_openvpn_service:
  service.running:
    - name: openvpn@crypto_gateway_client
    - enable: True
