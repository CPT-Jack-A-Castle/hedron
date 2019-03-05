#!/bin/sh

set -e

# Persistence layer for brainvault.

fail() {
    echo "$@" >&2
    echo Aborting...
    exit 1
}

# Open up umask. Security is based on filename unpredictability. This lets us use this with johndoe.
umask 0000

BRAINVAULT_HASH=$(cat ~/.brainvault/hash)

# Load preferences from ~/.brainvaultrc
# shellcheck disable=SC1090
[ -f ~/.brainvaultrc ] && . ~/.brainvaultrc

BRAINVAULT_HASHED=$(brainkey password_hash "$BRAINVAULT_HASH" brainvault_persistence)
BRAINVAULT_HASHED_FILENAME=$(brainkey password_hash "$BRAINVAULT_HASH" brainvault_persistence_filename)
EMAIL_DOMAIN=$(cat ~/.brainvault/email_domain)

EPOCH=$(date +%s)

# We divide epoch by ten for a lower but faster resolution.
LESSER_EPOCH=$((EPOCH / 10))X
BRAINVAULT_BACKUP_FILE="/var/tmp/brainvault-persistence/$BRAINVAULT_HASHED_FILENAME-$LESSER_EPOCH.tar.xz.ccrypt"

backup_available() {
    if [ "$1" = '--specific' ]; then
        brainvault_persistence_py locate_backup "$BRAINVAULT_HASH" "$1" "$2"
    else
        brainvault_persistence_py locate_backup "$BRAINVAULT_HASH"
    fi
}

# Consider ignoring certain files. Maybe a sourced file list of things to ignore? Although I think tar has an option for that already, some kind of .gitignore style thing. Or maybe that's just rsync?
# Maybe consider including certain files ignore. We are ignoring most dotfiles so we don't backup silly stuff like Firefox cache. Browsers shouldn't be ran in xorg_vm anyway.
# Changing backups from absolute to relative paths.
backup() {
    cd ~/
    date +%s > .brainvault-persistence.epoch
    # shellcheck disable=SC2086
    tar -cf - ./* .sandbox/bitmessage/.config/PyBitmessage/keys.dat .brainvaultrc .brainvault .brainvault-persistence.epoch .bitmessage-muttrc .bashrc .ssh .sporestackv2 .keyplease .gitconfig .gnupg .irssi $BRAINVAULTRC_PERSISTENCE_INCLUDES | xz | ccrypt -K "$BRAINVAULT_HASHED" > "$BRAINVAULT_BACKUP_FILE"
    # Give the user an idea of how big their archive is.
    du -h "$BRAINVAULT_BACKUP_FILE"
    # Hope this gets synced to disk so we can rely on it.
    sync
    if [ "$1" = '--mega' ]; then
         echo Uploading to Mega...
         brainvault_persistence_py mega_upload_brainvault_archive "$BRAINVAULT_HASH" "$BRAINVAULT_BACKUP_FILE" --email_domain "$EMAIL_DOMAIN"
         echo ...Finished upload to Mega
    fi
}

extract() {
    if [ "$1" = '--mega' ]; then
        brainvault_persistence_py mega_download_brainvault_archive "$BRAINVAULT_HASH" --email_domain "$EMAIL_DOMAIN"
        brainvault_backup_file=$(backup_available --specific 0)
    else
        brainvault_backup_file=$(backup_available)
    fi
    ccdecrypt -c -K "$BRAINVAULT_HASHED" "$brainvault_backup_file" | tar -xJf - -C "$HOME"
}

COMMAND=$1
OPTION=$2

if [ -n "$OPTION" ]; then
    [ "$OPTION" != '--mega' ] && fail '--mega is the only option.'
    # Fail out if the account doesn't actaully exist.
    brainvault_persistence_py mega_account_exists "$BRAINVAULT_HASH" --email_domain "$EMAIL_DOMAIN" || fail 'MEGA account does not exist for that brainvault.'
fi

case "$COMMAND" in
    backup_available)
        backup_available "$OPTION"
        ;;
    backup)
        backup "$OPTION"
        ;;
    extract)
        extract "$OPTION"
        ;;
    *)
        fail 'Invalid usage.'
        ;;
esac

echo 'Success.'
