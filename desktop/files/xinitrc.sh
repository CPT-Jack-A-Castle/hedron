#!/bin/sh

set -e

if [ -f /etc/X11/desired_resolution ]; then
    RESOLUTION=$(cat /etc/X11/desired_resolution)
    if echo "$RESOLUTION" | grep -q 'x'; then
        if ! xrandr | grep -qF "$RESOLUTION"; then
            # shellcheck disable=SC2046
            xrandr --newmode "$RESOLUTION" $(cvt $(echo "$RESOLUTION" | tr 'x' ' ') | tail -n 1 | cut -d ' ' -f 3-)
            xrandr --addmode Virtual-1 "$RESOLUTION"
        fi
        xrandr -s "$RESOLUTION"
        xrandr --dpi 96
    fi
fi

su - user -c dwm
# su - user -c 'openbox --sm-disable'
