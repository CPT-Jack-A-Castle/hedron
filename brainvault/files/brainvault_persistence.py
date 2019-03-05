#!/usr/bin/env python3

import os
import logging
from time import time
from sys import exit

import aaargh
import hedron
import brainkey
from sh import megals, megaput, megaget, megarm, ErrorReturnCode_1

logger = logging.getLogger(__name__)

BV_PERSISTENCE_PATH = "/var/tmp/brainvault-persistence"
BV_SUFFIX = '.tar.xz.ccrypt'
BRAINVAULT_VERSIONED = BV_PERSISTENCE_PATH + "/{}-{}X" + BV_SUFFIX

cli = aaargh.App()


def brainvault_backup_path(brainvault_hashed, specific):
    hashed = brainkey.password_hash(brainvault_hashed,
                                    'brainvault_persistence_filename')
    path = BRAINVAULT_VERSIONED.format(hashed, specific)
    return path


@cli.cmd
@cli.cmd_arg('brainvault_hashed')
@cli.cmd_arg('--max_days', default=None, type=int)
# --specific is without the X. FIXME: Should be in help output.
@cli.cmd_arg('--specific', default=None, type=int)
def locate_backup(brainvault_hashed, max_days=None, specific=None):
    if specific is not None:
        if max_days is not None:
            raise ValueError('Cannot set max_days and specific together.')
        brainvault_backup_file = brainvault_backup_path(brainvault_hashed,
                                                        specific)
        if os.path.isfile(brainvault_backup_file):
            return brainvault_backup_file
        else:
            return False
    else:
        if max_days is None:
            max_days = 14
    # Our epoch is /10 for a faster and lower resolution.
    epoch = int(time() / 10)
    # 8640, not 86400 since we are doing epoch/10.
    min_epoch = epoch - max_days * 8640
    while epoch > min_epoch:
        brainvault_backup_file = brainvault_backup_path(brainvault_hashed,
                                                        epoch)
        if os.path.isfile(brainvault_backup_file):
            return brainvault_backup_file
        epoch = epoch - 1
    return False


@cli.cmd
def prune_backups():
    """
    Prune all but the oldest backups. This will break naturally
    if the user doesn't have permission.
    """
    # We make some bad assumptions, like all files being in the
    # naming right format.
    all_backups = os.listdir(BV_PERSISTENCE_PATH)
    latest_backups = hedron.latest_only(all_backups)
    for backup in all_backups:
        if backup not in latest_backups:
            os.remove(os.path.join(BV_PERSISTENCE_PATH, backup))
    return True


##
# MEGA features.
# No recent Python libraries out there. Since our MEGA use is pretty simple,
# using megatools through the sh module is probably the best bet... for now.

def mega_username_and_password(brainvault_hashed,
                               email_domain):
    public = brainkey.public(brainvault_hashed)
    username = '{}@{}'.format(public, email_domain)
    password = brainkey.password(brainvault_hashed, 'mega.nz')
    return username, password


@cli.cmd
@cli.cmd_arg('brainvault_hashed')
@cli.cmd_arg('--email_domain', required=True)
def mega_account_exists(brainvault_hashed, email_domain):
    username, password = mega_username_and_password(brainvault_hashed,
                                                    email_domain)
    try:
        megals('--username', username,
               '--password', password)
    except ErrorReturnCode_1:
        return False
    return True


@cli.cmd
@cli.cmd_arg('brainvault_hashed')
@cli.cmd_arg('path_to_brainvault_archive')
@cli.cmd_arg('--email_domain', required=True)
def mega_upload_brainvault_archive(brainvault_hashed,
                                   path_to_brainvault_archive,
                                   email_domain):
    username, password = mega_username_and_password(brainvault_hashed,
                                                    email_domain)
    remote_path = '/Root/brainvault' + BV_SUFFIX
    # megaput fails if the destination already exists.
    # So, delete it if it does.
    # Unfortunately, megals does not return 1 if it does not exist,
    # only returns a newline.
    # This is fragile... probably are better ways to do this.
    if megals('--username', username,
              '--password', password,
              remote_path).strip('\n') == remote_path:
        logger.info('Existing archive in MEGA detected. Deleting...')
        megarm('--username', username,
               '--password', password,
               remote_path)
    megaput('--username', username,
            '--password', password,
            '--path', remote_path,
            '--no-progress',
            '--disable-previews',
            path_to_brainvault_archive)
    return True


@cli.cmd
@cli.cmd_arg('brainvault_hashed')
@cli.cmd_arg('--email_domain', required=True)
def mega_download_brainvault_archive(brainvault_hashed,
                                     email_domain):
    username, password = mega_username_and_password(brainvault_hashed,
                                                    email_domain)

    path_to_brainvault_archive = brainvault_backup_path(brainvault_hashed, 0)
    remote_path = '/Root/brainvault' + BV_SUFFIX

    # megaget refuses to overwrite files, so check if it exists and delete
    # if it does.
    if os.path.exists(path_to_brainvault_archive):
        logger.info('Existing local archive detected. Deleting...')
        os.remove(path_to_brainvault_archive)
    megaget('--username', username,
            '--password', password,
            '--path', path_to_brainvault_archive,
            '--no-progress',
            remote_path)
    return True
##


if __name__ == '__main__':
    output = cli.run()
    if output is True:
        exit(0)
    elif output is False:
        exit(1)
    elif output is None:
        exit(0)
    else:
        print(output)
