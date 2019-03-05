# DynamicUser implies PrivateTmp which gives us our own /var/tmp namespace.
# Bandwidth rate should be configurable.
# When Tor adds IPv6 support to 'auto', remove the second ORPort.
# Not adding bridge to this since relays can't use bridges.
hedron_tor_relay_service_file:
  file.managed:
    - name: /etc/systemd/system/tor_relay.service
    - contents: |
        [Unit]
        Description=Tor relay
        After=network.target
        [Service]
        DynamicUser=yes
        # Current systemd is broken with DynamicUser / named Group combinations
        # Should be equivalent.
        Group=67
        UMask=0077
        RuntimeDirectory=tor_relay
        ExecStart=/usr/sbin/tor --ignore-missing-torrc -f /dev/null --SocksPort 0 --ClientUseIPv6 1 --ClientPreferIPv6ORPort 1 --DataDirectory /var/tmp/tor --ORPort auto --ORPort "[{{ grains['ip6_interfaces']['eth0'][0] }}]:1100 IPv6Only" --BandwidthRate 2MBits --ExitRelay 0 --CellStatistics 0 --PaddingStatistics 0 --DirReqStatistics 0 --HiddenServiceStatistics 0 --ExtraInfoStatistics 0 --ControlPort "unix:/run/tor_relay/control RelaxDirModeCheck"
        OOMScoreAdjust=100
        Restart=on-failure
        RestartSec=5

hedron_tor_relay_service_running:
  service.running:
    - name: tor_relay
    - enable: True
    - watch:
      - file: /etc/systemd/system/tor_relay.service
