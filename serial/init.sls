# We are enabling serial consoles at install time but it doesn't work on a lot of systems.
# This should test if it's not working and disable it if it is.

# This sure is a bit of a mess. Does have to be very specific, though. No unless/onlyif for service.disabled.

hedron_serial_unless_script:
  file.managed:
    - name: /usr/local/sbin/serial-check
    - source: salt://hedron/serial/files/serial-check.sh
    - mode: 0755

hedron_serial_disable_if_needed:
  cmd.run:
    - name: systemctl disable --now serial-getty@ttyS0.service
    - unless: serial-check
