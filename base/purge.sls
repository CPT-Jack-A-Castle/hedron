# Make sure these things are not installed or running.

# Note about network-manager, gnome-terminal, and console-setuplinux:
# Remove these. If install fails and you retry, it can install extra packages that cause problems.

hedron_base_purge_packages:
  pkg.purged:
    - pkgs:
      - network-manager
      - gnome-terminal
      - console-setup-linux
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

# This is not as reliable as ntpd.
hedron_base_purge_timesync_service:
  service.dead:
    - name: systemd-timesyncd
    - enable: False
