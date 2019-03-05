#!/bin/sh

# Intended only for use as root, at least for now.

set -e

umask 0077

HOSTNAME=$1

# MACHINE_ID=$(sporestackv2 get_attribute "$HOSTNAME" machine_id)
SLOT=$(sporestackv2 get_attribute "$HOSTNAME" slot)
HOST=$(sporestackv2 get_attribute "$HOSTNAME" host)
SSHHOSTNAME=$(sporestackv2 get_attribute "$HOSTNAME" sshhostname)
SSHPORT=$(sporestackv2 get_attribute "$HOSTNAME" sshport)

if [ "$HOST" = "127.0.0.1" ]; then
    SSHHOSTNAME=127.0.0.1
    SSHPORT="$SLOT"
fi

[ "$SSHPORT" = "null" ] && SSHPORT=22

VM_DIR="/etc/sporestackv2_salt/$HOSTNAME"

if [ ! -d "$VM_DIR" ]; then
    mkdir -p "$VM_DIR"
# FIXME: Dunno about this formatting so leaving it ugly.
echo "$HOSTNAME:
  host: $SSHHOSTNAME
  port: $SSHPORT
  minion_opts:
    log_level_logfile: debug
    failhard: True" > "$VM_DIR/roster"

echo 'file_roots:
  base:
    - /srv/salt
pillar_roots:
  base:
    - /srv/salt/private_pillar
    - /srv/salt/pillar
failhard: True' > "$VM_DIR/master"
fi

salt_this_vm() {
    salt-ssh --priv "$(keyplease private "$HOSTNAME")" --no-host-keys -c "/etc/sporestackv2_salt/$HOSTNAME" --log-file /dev/null "$HOSTNAME" "$@"
}

# FIXME: Make sure we have something planned for it.
# Want to catch failures where the roster file is bad.
#salt_this_vm state.highstate test=True || true

until salt_this_vm test.ping | grep True; do
    sleep 5
done


# Run it with test=True to show ordering.
# This one actualy can fail but at least shows us handy data.
# This slows us down a lot, better to do this manually if need be.
# salt_this_vm state.highstate test=True || true

# If not already salted, give one highstate grace period for tmpfs and what not.
# Maybe should do state.sls hedron.base? Although that is making the assumption if we want base or not, which is already defined in top.sls.
if salt_this_vm file.access /.salted f | grep False; then
    salt_this_vm state.highstate || true
fi

# This should be successful, hopefully.
salt_this_vm state.highstate

# See if at least basic salting happened
salt_this_vm file.access /.salted f | grep True

touch "$VM_DIR/salted"
