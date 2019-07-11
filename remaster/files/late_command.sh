#!/bin/sh

# Logs from this are visible in /var/log/syslog during install, and /var/log/installer/syslog after install.

set -e

echo "$PATH"

set

logsomething() {
    # FIXME: Broken?
    # log-output -t apt-install "Running late_command."
    # logger -t doesn't output to console.
    # Just using echo as a safe fallback.
    echo "LOGSOMETHING: $*"
}

cp -r /cdrom/salt /target/srv/
cp -r /cdrom/salt/private_pillar /target/srv/pillar || cp -r /cdrom/salt/pillar /target/srv/
chmod 700 /target/srv/salt
chmod 700 /target/srv/pillar

logsomething "Installing salt-minion..."

apt-install salt-minion
# This needs compiler/autoconf and all.
#apt-install python3-pip python3-setuptools python3-wheel
#in-target pip3 install salt

logsomething "...Installed salt-minion."

# Pillar copying is a bootstrapping hack until we get a minion config in place to tell it where to properly look for the pillar data.
# FIXME: Consider using --pillar-root instead?
# We do the hostname replacement because dhcp may make the minion think it's workstation.somuchwow and not workstation. We fix that later in salt but it's an issue at this point.
logsomething "Grabbing minion ID."
# shellcheck disable=SC2154
MINION_ID=$hostname

if [ -z "$MINION_ID" ]; then
    MINION_ID=iforgottosetthehostname
    logsomething "You forgot to set the hostname."
fi

logsomething "Running salt."
# Minimal salt prep, grains, etc.
in-target salt-call -l info --local state.sls hedron.base.salt failhard=True --id="$MINION_ID"
# firstboot
in-target salt-call -l info --local state.sls hedron.base.firstboot failhard=True --id="$MINION_ID"

# We do the hard work after the reboot.
logsomething "Enabling firstboot."
in-target systemctl enable firstboot
logsomething "Enabling debug-shell."
in-target systemctl enable debug-shell

# Stupidly, Debian leaves the cdrom apt source which isn't mounted and we get hung on.

in-target sed -i /cdrom/d /etc/apt/sources.list
