#!/bin/sh

# Generally intended to only have one brainvault identity per VM.

set -e

umask 0077

fail() {
    echo "$@"
    echo Aborting...
    exit 1
}

[ "$USER" != 'user' ] && echo "You probably want to run this as 'user' and not as '$USER', but continuing anyway."

[ $# -lt 1 ] && fail "Usage: $0: <brainvault> [--fetch_from] (default: local_filesystem|none|mega) [--email_domain] (default: elude.in|tutanota.com|others)"

BRAINVAULT=$1

shift

ARGS_FETCH_FROM="local_filesystem"
ARGS_EMAIL_DOMAIN="elude.in"
# shellcheck disable=SC2048
for argument in $*; do
    # If we get a non -- argument, hopefully it was processed already.
    if echo "$argument" | grep -v -q -- '--.*'; then
        continue
    fi
    if [ "$argument" = "--fetch_from" ] ; then
        shift
        ARGS_FETCH_FROM="$1"
    elif [ "$argument" = "--email_domain" ]; then
        shift
        ARGS_EMAIL_DOMAIN="$1"
    else
        fail "Unrecognized argument: $argument"
    fi
done


# This should only happen in an empty home directory (like /home/user after a reboot).
# Unfortunately, $HOME is never empty from .bash_history.
# We'll just check for ~/.ssh and call it a day at that.

[ -d ~/.ssh ] && fail "Should be ran in a virgin home. ~/.ssh detected."

BRAINVAULT_HASH=$(brainkey passphrase_to_hash "$BRAINVAULT")
# For brainvault-persistence
mkdir ~/.brainvault
echo "$BRAINVAULT_HASH" > ~/.brainvault/hash
echo "$ARGS_EMAIL_DOMAIN" > ~/.brainvault/email_domain

if [ "$ARGS_FETCH_FROM" = 'mega' ]; then
    echo 'Downloading and extracting from mega...'
    brainvault-persistence extract --mega
    # This is mainly for writing /var/lib/notbit/keys.dat on a fresh system, but extracting from archives.
    # notbit is too unstable for this use, so disabling it at least for now.
    # brainvault-bitmessage "$BRAINVAULT" || true
elif [ "$ARGS_FETCH_FROM" = 'local_filesystem' ]; then
    if brainvault-persistence backup_available; then
        echo "Brainvault backup detected. Extracting..."
        brainvault-persistence extract
        echo "...Extracted"
        # This is mainly for writing /var/lib/notbit/keys.dat on a fresh system, but extracting from archives.
        # FIXME: Redundant
        # Disabled.
        # brainvault-bitmessage "$BRAINVAULT" || true
    else
        echo "No Brainvault backup found. Ignoring."
        echo "Think you have one? Try brainvault-persistence extract --max_days XXX or --specific EPOCH"
        echo "Running brainvault-skel to populate your virgin home directory..."
        brainvault-skel "$BRAINVAULT" "$BRAINVAULT_HASH" "$ARGS_EMAIL_DOMAIN"
    fi
elif [ "$ARGS_FETCH_FROM" = 'none' ]; then
        brainvault-skel "$BRAINVAULT" "$BRAINVAULT_HASH" "$ARGS_EMAIL_DOMAIN"
else
    fail "Only mega or local_filesystem supported for --fetch_from"
fi

echo 'Create backups with "brainvault-persistence backup".'

if [ -f ~/.bashrc ]; then
echo "Run: . ~/.bashrc"
fi

# Do this here rather than in skel because it's not normally backed up.
# Even with umask 0077, Firefox creates Downloads as chmod 0700, but the files under it are fine. Make it, then it won't mess it up.
mkdir -p ~/.sandbox/browser/Downloads

# Reset permissions here. After extraction of an archive, ownership will change and this should fix things up.
# FIXME: This should be 770 for already executable (and directories) and 660 for otherwise.
chmod -R 0770 ~/.sandbox

mkdir ~/.sandbox_launch

# Display information about bitcoin address, bitmessage address, etc.
brainvault-banner

if [ -n "$DISPLAY" ]; then
    echo 'Updating statusbar...'
else
    echo 'A brief summary...'
fi

brainvault_dwm_statusbar || true

echo Success
