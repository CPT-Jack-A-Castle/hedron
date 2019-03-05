include:
  - hedron.tor
  - hedron.tornet.notor_user

clearnet_socks_exit_packages:
  pkg.installed:
    - pkgs:
      - dante-server

# Can consider adding random username/password to this.

clearnet_socks_exit_configuration:
  file.managed:
    - name: /etc/danted.conf
    - contents: |
        logoutput: stderr
        internal: 127.0.0.1 port = 1080
        external.protocol: ipv6 ipv4
        external: eth0
        socksmethod: none
        clientmethod: none
        user.notprivileged: notor
        client pass {
            from: 0/0 to: 0/0
        }
        socks pass {
            from: 0/0 to: 0/0
        }

clearnet_socks_exit_service:
  service.running:
    - name: danted
    - enable: True
    - watch:
      - file: /etc/danted.conf

clearnet_socks_exit_tor_config:
  file.managed:
    - name: /etc/tor/hiddenservice_clearnet_socks_exit.torrc
    - contents: |
        HiddenServiceDir /etc/tor/hiddenservice_clearnet_socks_exit
        HiddenServiceVersion 3
        HiddenServicePort 1080 127.0.0.1:1080
        HiddenServiceNonAnonymousMode 1
        HiddenServiceSingleHopMode 1
        SocksPort 0
        DataDirectory /tmp/tor-clearnet_socks_exit

clearnet_socks_exit_tor_service:
  service.running:
    - name: tor@hiddenservice_clearnet_socks_exit
    - enable: True
    - watch:
      - file: /etc/tor/hiddenservice_clearnet_socks_exit.torrc
