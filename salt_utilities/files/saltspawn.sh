#!/bin/sh

set -e

# Spawns a with a given hostname and then highstates with Salt.
SALTHOSTNAME=$1

if [ $# -lt 2 ]; then
    echo "Usage: $0 <hostname> (other stuff for sporestackv2 like --days 1)>"
    exit 1
fi

shift 1

# Show organization that the pillar data has set.
salt-call --no-color --retcode-passthrough -c salt/hedron/salt_utilities/files/ --local --log-file=/dev/null --out=txt pillar.get hedron.organization 2> /dev/null

WALKINGLIBERTY=$(salt-call --no-color --retcode-passthrough -c salt/hedron/salt_utilities/files/ --local --log-file=/dev/null --out=txt pillar.get hedron.walkingliberty 2> /dev/null | awk '{print $NF}')
CURRENCY=$(salt-call --no-color --retcode-passthrough -c salt/hedron/salt_utilities/files/ --local --log-file=/dev/null --out=txt pillar.get hedron.walkingliberty.currency 2> /dev/null | awk '{print $NF}')
echo "Using wallet of $WALKINGLIBERTY and paying with $CURRENCY in 5 seconds..."
sleep 5

keyplease generate "$SALTHOSTNAME"
PUB_KEY_FILE=$(keyplease public "$SALTHOSTNAME")

# salt/hedron/ipxe_scripts/files/ipxe-stretch.sh "$PUB_KEY_FILE" | sporestackv2 launch --ipxescript_stdin True --ipv4 /32 --ipv6 /128 --bandwidth 1 --memory 1 --disk 10 --cores 1 --currency "$CURRENCY" --walkingliberty_wallet "$WALKINGLIBERTY" --ssh_key "$PUB_KEY" --operating_system debian-9 "$SALTHOSTNAME" "$@"
# We now support operating_system and ssh_key in vmmanagement_baremetal. There's some advantages to using it instead of iPXE (it, itself uses iPXE), so we will do that for now.
sporestackv2 launch --ipv4 /32 --ipv6 /128 --bandwidth 1 --memory 1 --disk 10 --cores 1 --currency "$CURRENCY" --walkingliberty_wallet "$WALKINGLIBERTY" --ssh_key_file "$PUB_KEY_FILE" --operating_system debian-10 "$SALTHOSTNAME" "$@"

# shellcheck disable=SC2029
DNSHOSTNAME=$(sporestackv2 get_attribute "$SALTHOSTNAME" sshhostname)
salt/hedron/qemu/files/sshwait.py "$DNSHOSTNAME"
PRIV_KEY_FILE=$(keyplease private "$SALTHOSTNAME")

# sleep 180 has been needed with tor networking before.

for possible_path in /etc/sporestackv2/$SALTHOSTNAME.json ~/.sporestackv2/$SALTHOSTNAME.json; do
    if [ -r "$possible_path" ]; then
        file_path="$possible_path"
        break
   fi
done

if [ -z "$file_path" ]; then
    "No file path found for sporestackv2??? Aborting."
    exit 1
fi

echo "$file_path chosen"

EXPIRATION=$(sporestackv2 get_attribute "$SALTHOSTNAME" expiration)

# /etc/sporestack/end_of_life is kind of a legacy hack that we still need for autodisable.
# shellcheck disable=SC2029
ready_server() {
    ssh -i "$PRIV_KEY_FILE" -l root "$DNSHOSTNAME" -oStrictHostKeyChecking=no -oBatchMode=yes -oUserKnownHostsFile=/dev/null "mkdir /etc/sporestack; chmod 700 /etc/sporestack; echo $EXPIRATION > /etc/sporestack/end_of_life; mkdir /etc/sporestackv2; chmod 700 /etc/sporestackv2; cat > /etc/sporestackv2/$SALTHOSTNAME.json" < "$file_path"
    # shellcheck disable=SC2181
    if [ $? -ne 0 ]; then
        echo "Sleeping for ten seconds in ready_server..."
        sleep 10
        false
    fi
}

# This helps with autorenewal, also waits till we're online.
# Three tries
ready_server || ready_server || ready_server

echo "$SALTHOSTNAME:
  host: $DNSHOSTNAME
  minion_opts:
    failhard: True
" >> salt/roster

./salt/hedron/salt_utilities/files/saltshaker.sh "$SALTHOSTNAME"
