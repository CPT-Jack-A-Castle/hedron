# FIXME: Needs to be updated to HTTP?
# Just SSH port 1060 for serialconsole.

hedron_vmmanagement_hiddenservice_torrc:
  file.managed:
    - name: /etc/tor/vmmanagement.torrc
    - contents: |
        SocksPort 0
        HiddenServiceDir /etc/tor/vmmanagement
        HiddenServicePort 1060 127.0.0.1:1060
        DataDirectory /tmp/tor-vmmanagement

hedron_vmmanagement_hiddenservice_tor_running:
  service.running:
    - name: tor@vmmanagement
    - enable: True
    - watch:
      - file: /etc/tor/vmmanagement.torrc
