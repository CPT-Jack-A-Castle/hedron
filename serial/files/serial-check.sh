#!/bin/sh

# If the serial getty isn't enabled, just bail out and exit 0. No change needed.
systemctl is-enabled serial-getty@ttyS0.service || exit 0

# If it is, try to read from /dev/ttyS0. If it's broken, it'll fail differently.
timeout 0.1 head -c 1 /dev/ttyS0 > /dev/null
# Will return 1 if a serial failure, 124 if timeout kills it. 124 or 0 is good.
[ $? -eq 124 ] && exit 0
