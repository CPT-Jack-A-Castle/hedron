include:
  - .package

hedron_monero_mainnet_service_file:
  file.managed:
    - name: /etc/systemd/system/monero.service
    - source: salt://hedron/monero/files/monero.service

hedron_monero_mainnet_group:
  group.present:
    - name: monero

hedron_monero_mainnet_user:
  user.present:
    - name: monero
    - gid_from_name: True
    - home: /home/monero
    - createhome: True
    - shell: /bin/false

# Won't restart if we upgrade the version.
hedron_monero_mainnet_service_running:
  service.running:
    - name: monero
    - enable: True
    - watch:
      - file: /etc/systemd/system/monero.service

hedron_monero_mainnet_custom_wallet_rpc_service_file:
  file.managed:
    - name: /etc/systemd/system/monero-rpc-wallet-custom@.service
    - source: salt://hedron/monero/files/monero-rpc-wallet-custom@.service
