# Disables /etc/network/interfaces system in favor of systemd-networkd

# Once this happens it seems to drop the link on eth0.
hedron_base_networking_legacy_disable_service:
  service.dead:
    - name: networking
    - enable: False

# There's also this ifup service to get rid of...
hedron_base_networking_legacy_disable_ifup_eth0:
  service.dead:
    - name: ifup@eth0
    - enable: False

hedron_base_networking_legacy_disable_remove_ifup_service:
  file.absent:
    - name: /lib/systemd/system/ifup@.service

# In case that's the case try to flip the link up. This is kind of a hack to try and get red_vm to come up without restarting the VM.
# FIXME: I don't really like this in case we want eth0 down for some reason.
hedron_base_networking_legacy_disable_eth0_back_up:
  cmd.run:
    - name: ip link set eth0 up
    - onlyif: 'ip link show eth0 | grep DOWN'

# Make a note to help make this more obvious.
hedron_base_networking_legacy_disable_leave_a_note:
  file.managed:
    - name: /etc/network/interfaces
    - contents: '# This has been disabled in favor of systemd-networkd'
