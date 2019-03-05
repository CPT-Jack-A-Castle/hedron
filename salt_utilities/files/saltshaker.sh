#!/bin/sh

# This waits for a vm to come online and then salts it. It exits 0 if successful, 1 if a failure.

set -e

SALTHOSTNAME=$1

until ./salt/hedron/salt_utilities/files/salt-ssh.sh "$SALTHOSTNAME" test.ping | grep True; do
    sleep 10
done

# The first one will probably fail as /tmp gets tmpfs mounted.
# 5 tries is mainly for potential of network failure
# More is nice for reliability, less is nice for knowing the salt code works in one pass.

for tries in 1 2 3 4 5; do
    # || true to catch failures gracefully, kinda. salt-ssh may not even exit with 1
    ./salt/hedron/salt_utilities/files/salt-ssh.sh "$SALTHOSTNAME" state.highstate || true
    # See if at least basic salting happened. salt-ssh doesn't pass return codes.
    if ./salt/hedron/salt_utilities/files/salt-ssh.sh "$SALTHOSTNAME" file.access /.salted f | grep True; then
        echo "DEBUG: saltshaker tries: $tries"
        echo "Server ready: $SALTHOSTNAME"
        exit 0
    fi
done

echo "CRITICAL: saltshaker for $SALTHOSTNAME failed"

# No successes if we get to this point, so break.
exit 1
