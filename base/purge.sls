# Make sure these things are not installed or running.

# Note about network-manager, gnome-terminal, and console-setuplinux:
# Remove these. If install fails and you retry, it can install extra packages that cause problems.

# logrotate usually needs configuration to work properly. Can be good to have but was failing out of the box on a Debian 10 box, so just taking it out for now.

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
      - logrotate

# This is not as reliable as ntpd.
hedron_base_purge_timesync_service:
  service.dead:
    - name: systemd-timesyncd
    - enable: False

## This failed on one system and I think very little actually needs it.
hedron_base_purge_binfmt_automount_service:
  service.dead:
    - name: proc-sys-fs-binfmt_misc.automount
    - enable: False

hedron_base_purge_binfmt_service:
  service.dead:
    - name: proc-sys-fs-binfmt_misc.mount
    - enable: False
##
