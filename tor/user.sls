# Creates the debian-tor user so we can have consistent IDs.
# This must be ran before installing the tor package.

# unique: False still failed with an existing group. We can could
# use a cmd.run to change the ID, but then we'd have to worry about
# /etc/tor permissions being out of whack...

# So sadly, this is a breaking change.

# The "home" setting is partly to appease the tor package install script.
# If you set uid and gid, the group will not use gid. Dumb bug.
# Seems to only occur in lower uid/gid ranges?
# Anyway...
# Small update. This *might* work if no processes are running with the
# current uid/gid when it runs.

hedron_tor_client_user_group:
  group.present:
    - name: debian-tor
    - gid: 67

hedron_tor_client_user:
  user.present:
    - name: debian-tor
    - uid: 67
    - gid: 67
    - home: /var/lib/tor
    - createhome: False
    - shell: /bin/false
