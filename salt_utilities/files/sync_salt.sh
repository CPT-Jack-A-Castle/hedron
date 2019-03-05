#!/bin/sh

HOST=$1

shift

rsync -L --rsh="ssh $*" --delete-after -Erxv ./salt/ "root@$HOST:/srv/salt" --exclude .git --exclude __pycache__ --exclude '*.pyc' --filter 'protect dist' --filter 'protect dist/*'
