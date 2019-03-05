include:
  - hedron.tor

hedron_wekan_hidden_service_torrc:
  file.managed:
    - name: /etc/tor/wekan.torrc
    - contents: |
        SocksPort 0
        HiddenServiceDir /etc/tor/hidden_service_wekan
        HiddenServicePort 80 127.0.0.1:80
        DataDirectory /tmp/tor-wekan

hedron_wekan_hidden_service_running:
  service.running:
    - name: tor@wekan
    - enable: True
    - watch:
      - file: /etc/tor/wekan.torrc
