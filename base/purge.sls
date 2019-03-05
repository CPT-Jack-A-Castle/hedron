# Make sure these things are not installed or running.

hedron_base_purge_packages:
  pkg.purged:
    - pkgs:
      - dnsmasq
      - exim4
      - exim4-daemon-light
      - exim4-base
      - exim4-config
      - bluetooth
      - bluez
      - avahi-autoipd
      - mailutils
      - mailutils-common
