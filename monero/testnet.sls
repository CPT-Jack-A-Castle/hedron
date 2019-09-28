include:
  - .package

hedron_monero_testnet_service_file:
  file.managed:
    - name: /etc/systemd/system/monero-testnet.service
    - source: salt://hedron/monero/files/monero-testnet.service

hedron_monero_testnet_group:
  group.present:
    - name: monero-testnet

hedron_monero_testnet_user:
  user.present:
    - name: monero-testnet
    - gid_from_name: True
    - home: /home/monero-testnet
    - createhome: True
    - shell: /bin/false

# Won't restart if we upgrade the version.
hedron_monero_testnet_service_running:
  service.running:
    - name: monero-testnet
    - enable: True
    - watch:
      - file: /etc/systemd/system/monero-testnet.service

hedron_monero_testnet_custom_wallet_rpc_service_file:
  file.managed:
    - name: /etc/systemd/system/monero-testnet-rpc-wallet-custom@.service
    - source: salt://hedron/monero/files/monero-testnet-rpc-wallet-custom@.service

hedron_monero_testnet_wallet_rpc_service_file:
  file.managed:
    - name: /etc/systemd/system/monero-testnet-rpc-wallet-demo.service
    - source: salt://hedron/monero/files/monero-testnet-rpc-wallet-demo.service

# Automating wallet creation is a real pain, would probably need to use expect.

# su - monero-testnet -s /bin/bash
# You'll land in the home directory.
# /usr/local/monero/monero-wallet-cli --testnet --generate-new-wallet demo-testnet-wallet
# No password
# Now you can systemctl enable --now monero-testnet-rpc-wallet-demo if you like.
