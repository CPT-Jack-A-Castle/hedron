include:
  - .networking
  - .firstboot

# Hack so that systemd services are actually enabled. We manually enable this in the installer.
# Running this at the end is also intentional.
# Don't want to stop this because it would kill salt in maybe a weird point.
hedron_base_salted_firstboot_service_disabled:
  service.disabled:
    - name: firstboot

hedron_base_salted_debug_shell_service_disabled:
  service.dead:
    - name: debug-shell
    - enable: False

# Run this last as sort of a way to see if salt was successful, especially with salt-ssh which doesn't pass return codes.
hedron_base_salted:
  file.managed:
    - name: /.salted
    - contents: ''
