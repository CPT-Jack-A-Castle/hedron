# Switch has to be manually activated.
# touch /var/tmp/deadmanswallet
# chmod 400 /var/tmp/deadmanswallet
# Write passphrase to /var/tmp/deadmanswallet
# Back up the passphrase!!!
#
# Run: echo '/usr/local/sbin/deadmanswallet' | at -t 2017-07-14
#
# Make sure only your key is in /root/.ssh/authorized_keys
#
# Deactivation: at -d 1
# And rm /var/tmp/deadmanswallet to be safe.
# Consider a dd then a sync over the file to securely delete it.
#
# Server should be paid and current. It will not autorenew.
# Make sure the server will flip the switch before the server expires.
#
# You can topup SporeStack servers past 28 days if you make the call
# multiple times.

include:
  - hedron.walkingliberty

hedron_deadmansswitch_packages:
  pkg.installed:
    - name: at

hedron_deadmansswitch_script:
  file.managed:
    - name: /usr/local/sbin/deadmanswallet
    - source: salt://hedron/deadmansswitch/files/deadmanswallet.sh
    - mode: 0500
