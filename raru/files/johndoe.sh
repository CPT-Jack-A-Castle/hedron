#!/bin/sh

set -e

# Makes a John Doe'd process. Basic, user-level isolation.
# Strips off environment and has them build and tear down a home.

if [ $# = 0 ]; then
    echo "Usage: $0 <command>"
    exit 1
fi

umask 0077

# Sometimes we have an .Xauthority and sometimes we don't.
if [ -f ~/.Xauthority ]; then
    XAUTHORITYBASE64=$(base64 ~/.Xauthority)
fi

# QT_X11_NO_MITSHM=1 is for pybitmessage and others. Window contents show up blank otherwise.
# shellcheck disable=SC2016
env -i PATH="$PATH" DISPLAY="$DISPLAY" TERM=xterm QT_X11_NO_MITSHM=1 LC_ALL=C.UTF-8 LANG=C.UTF-8 raru /bin/sh -c 'set -e; JOHNDOEHOME=$(mktemp -p /tmp -d johndoeXXXXXXX); export HOME=$JOHNDOEHOME; echo "$HOME"; echo '"$XAUTHORITYBASE64"' | base64 -d > ~/.Xauthority; cd; '"$*"'; rm -rf $JOHNDOEHOME'
