#!/bin/sh

set -e

# Trap all signals and do nothing with them.
# Don't want someone to ctrl+c in them middle of the script
# and tweak its behavior in bad ways.
trap '' $(seq 0 64)

fail() {
    # shellcheck disable=SC2048,SC2086
    echo $* >&2
    exit 1
}

serialconsole() {
    tty > /dev/null 2>&1 || fail 'No tty allocated. retry with: ssh -t'
    while true; do
        # Need both of these options.
        stty raw -echo
        socat unix-connect:serial stdio 2> /dev/null || true
        stty sane
        echo 'Unable to connect to serial console. Is the VM offline?' >&2
        sleep 1
    done
}

hostconfig() {
    # settlement_token is private.
    echo 'vmmanagement.json has private bits, ignoring.'
    # cat /etc/vmmanagement.json
}

info() {
    cat "/var/tmp/runqemu/$1/settings.json"
}

ipxescript() {
    # Allow up to 40,000 bytes, then trim awkwardly.
    # FIXME: Error if input is longer than this.
    head -c 40000 > tftp/boot.ipxe
    # FIXME: Small denial of service vulnerabilty. Should force only one command per VM and ratelimit requests?
    # Issue is that this is a locking command.
    ipxe_path="$(pwd)/tftp/boot.ipxe"
    iso_path="$(pwd)/ipxe.iso"
    ipxe_iso "$ipxe_path" "$iso_path"
}

bootorder() {
    file=$(mktemp)
    # Specifically limit it to 3 for the chance of catching bogus arguments.
    # Consider stripping 0x0d? Or others?
    head -c 3 > "$file"
    if grep -q -e '^n$' -e '^c$' -e '^nc$' -e '^cn$' "$file"; then
        cp "$file" bootorder
        unlink "$file"
    else
        unlink "$file"
        echo 'Invalid bootorder. Must be one of: c, n, nc, cn'
        exit 1
    fi
}

start() {
    date > start
    for seconds in 1 1 1 1; do
        sleep "$seconds"
        [ -S 'serial' ] && exit 0
    done
    exit 1
}

stop() {
    date > stop
    for seconds in 1 1 1 1; do
        sleep "$seconds"
        [ -S 'serial' ] || exit 0
    done
    # Without this, it always returns 0?
    exit 1
}

help() {
    echo 'USAGE: create, topup, start, stop, bootorder, ipxescript, serialconsole, help'
    echo 'All command except create are to be followed by the machine_id.'
    echo 'create takes json via stdin.'
}

status() {
    if [ -S 'serial' ]; then
        echo "Server online."
        exit 0
    else
        echo "Server offline."
        exit 1
    fi
}

# FIXME: This is not quite right...
exists() {
    if [ -f 'created' ]; then
        echo "Server exists."
        exit 0
    else
        echo "Server does not exist."
        exit 1
    fi
}

# This is intended to implement the absolute minimum of services for a VPS.
# create, topup, info, stop, start, bootorder, ipxescript, serialconsole

# As a shell, first argument is -c, then the rest follow.
shift 2> /dev/null || help

# Annoyingly, sshd doesn't seem to split the arguments. Or something up in that stack.
# So we have to split out the variables ourselves.

ARGUMENTS=$1

COMMAND=$(echo "$ARGUMENTS" | cut -d ' ' -f 1)
MACHINE_ID=$(echo "$ARGUMENTS" | cut -d ' ' -f 2)

# FIXME: Blegh.
if [ "$COMMAND" != 'create' ]; then
if [ "$COMMAND" != 'host_info' ]; then
if [ "$COMMAND" != 'help' ]; then
    echo "$MACHINE_ID" | grep -qF . && fail 'Invalid machine_id charaters.'
    echo "$MACHINE_ID" | tr -d '\n' | wc -c | grep -qF 64 || fail 'Invalid machine_id length.'
    cd "$MACHINE_ID" 2> /dev/null || fail 'machine does not exist.'
fi
fi
fi

# FIXME: Add notice about 4,000 byte limit!
case $COMMAND in
    create)
        head -c 4000 | vmmanagement_create
        ;;
    topup)
        head -c 4000 | vmmanagement_topup
        ;;
    host_info)
        vmmanagement_host_info
        ;;
    exists)
        exists
        ;;
    hostconfig)
        hostconfig
        ;;
    info)
        info "$MACHINE_ID"
        ;;
    serialconsole)
        serialconsole
        ;;
    status)
        status
        ;;
    ipxescript)
        ipxescript
        ;;
    bootorder)
        bootorder
        ;;
    start)
        start
        ;;
    stop)
        stop
        ;;
    *)
        help
        ;;
esac
