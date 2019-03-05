include:
  - hedron.iptables
  - hedron.openvpn

hedron_crypto_gateway_generate_openvpn_key:
  cmd.run:
    - name: openvpn --genkey --secret /etc/openvpn/crypto_gateway_static.key
    - creates: /etc/openvpn/crypto_gateway_static.key
    - umask: 0077

hedron_crypto_gateway_server_config:
  file.managed:
    - name: /etc/openvpn/crypto_gateway_server.conf
    - source: salt://hedron/crypto_gateway/files/server.conf.jinja
    - template: jinja
    - mode: 0400

hedron_crypto_gateway_client_config:
  file.managed:
    - name: /etc/openvpn/crypto_gateway_client.conf
    - source: salt://hedron/crypto_gateway/files/client.conf.jinja
    - template: jinja
    - mode: 0400

hedron_crypto_gateway_ip_forwarding:
  sysctl.present:
    - name: net.ipv4.ip_forward
    - value: 1

hedron_crypto_gateway_iptables:
  file.managed:
    - name: /etc/iptables.rules
    - source: salt://hedron/crypto_gateway/files/iptables.rules

hedron_crypto_gateway_openvpn_service_running:
  service.running:
    - name: openvpnovertor@crypto_gateway_server
    - enable: True
    - watch:
      - file: /etc/openvpn/crypto_gateway_server.conf
