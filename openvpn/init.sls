hedron_openvpn_package:
  pkg.installed:
    - name: openvpn

# Generate keys like this:
# openvpn_generate_key:
#   cmd.run:
#     - name: openvpn --genkey --secret /etc/openvpn/static.key
#     - creates: /etc/openvpn/static.key

hedron_openvpn_delete_init_d_openvpn:
  file.absent:
    - name: /etc/init.d/openvpn

hedron_openvpn_systemd:
  file.managed:
    - name: /lib/systemd/system/openvpn@.service
    - source: salt://hedron/openvpn/files/openvpn@.service

hedron_openvpn_overtor_systemd:
  file.managed:
    - name: /lib/systemd/system/openvpnovertor@.service
    - source: salt://hedron/openvpn/files/openvpnovertor@.service
