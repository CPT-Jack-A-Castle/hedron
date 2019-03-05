hedron_vmmanagement_baremetal_tor_config:
  file.managed:
    - name: /etc/tor/hiddenservice_vmmanagement_baremetal.torrc
    - contents: |
        HiddenServiceDir /etc/tor/hiddenservice_vmmanagement_baremetal
        HiddenServiceVersion 3
        HiddenServicePort 80 127.0.0.1:80
        HiddenServicePort 1060 127.0.0.1:1060
        SocksPort 0
        DataDirectory /tmp/tor-vmmanagement_baremetal

hedron_vmmanagement_baremetal_tor_service:
  service.running:
    - name: tor@hiddenservice_vmmanagement_baremetal
    - enable: True
    - watch:
      - file: /etc/tor/hiddenservice_vmmanagement_baremetal.torrc
