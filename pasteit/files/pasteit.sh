#!/bin/bash

# Can't find a way to get trap + set -e to work with /bin/sh, just using /bin/bash.

# https://stackoverflow.com/questions/35800082/how-to-trap-err-when-using-set-e-in-bash

set -eE

# Don't let temp file be world readable.
umask 0066

TEMP=$(mktemp)

# Write stdin to TEMP file.
cat > "$TEMP"

cleanup_temp() {
    rm "$TEMP"
}

cleanup() {
    echo "Cleaning up $TEMP" >&2
    cleanup_temp
    exit 1
}

# trap something 1..64 like this always invokes the trap on Bash 5 but not Bash 4.4 (5 is in Buster, 4.4 is in Stretch)
# Dunno if this is a bug but 1..15 makes more sense anyways if you man 7 signal.
trap cleanup $(seq 1 15)

# pasta.cf is currently down. Some quick references...
# Preseed up to .onion and returning .onion url.
#PRESEED=$(curl -s --show-error --fail --data-urlencode "content@$PRESEEDFILE" -d pasta_type=self_burning http://pastagdsp33j7aoq.onion/api/create | grep raw | awk '{print $NF}' | cut -d / -f -5)
#PRESEED=$(curl -s --show-error --fail --data-urlencode "content@$PRESEEDFILE" -d pasta_type=self_burning https://pasta.cf/api/create | grep raw | awk '{print $NF}' | cut -d / -f -5)

stikked() {
    ENDPOINT=$1
    PASTE_FILE=$2
    output=$(curl -s --show-error --fail -d private=1 -d expire=burn --data-urlencode text@"$PASTE_FILE" "$ENDPOINT"/api/create)
    # shellcheck disable=SC2181
    [ $? -ne 0 ] && return
    pasteid=$(echo "$output" | grep -o '/[a-z0-9]*$' | tr -d /)
    [ -z "$pasteid" ] && return
    url="$ENDPOINT/view/raw/$pasteid"
    # Logging, ish.
    # echo "$output" >&2
    echo -n "$url"
}

burnpaste() {
    ENDPOINT=$1
    PASTE_FILE=$2
    pasteid=$(curl -s --show-error --fail --data-urlencode data@"$PASTE_FILE" "$ENDPOINT"/write)
    # shellcheck disable=SC2181
    [ $? -ne 0 ] && return
    [ -z "$pasteid" ] && return
    url="$ENDPOINT/read/$pasteid"
    # Logging, ish.
    # echo "$output" >&2
    echo -n "$url"
}

success() {
    cleanup_temp
    # echo Success >&2
    exit 0
}

# Retry logic in case of networking, tor, API flakiness, etc. Don't want to go forever, but want to be generous.
try=0
max_tries=100
while [ $try -ne $max_tries ]; do

    # For stikked, these were all the working HTTPS options that behaved fine over Tor, as found on duckduckgo.
    # shellcheck disable=SC2043
    for paste_api in "stikked http://paste.p-os.com" "stikked https://paste.morestina.net"; do
        paste_url=$($paste_api "$TEMP") || true
        if [ -n "$paste_url" ]; then
            echo "$paste_url"
            success
        fi
        try=$((try + 1))
        echo "Retrying paste... Try number: $try out of $max_tries" >&2
        sleep 2
    done

done

# pastebin notes:
# https is preferable in some ways, but expect this content to be public.
# stikked:
# paste.morestina.net has been unstable before.
# spit.mixtape.moe was great till it went down.
# paste.scratchbook.ch needs an API key.
# ironwolfmc.net gives a 403
# paste.bitlair.nl is blank.
# paste.tinyw.in gives a 404 and seems like an old version without burn support.
# paste.feed-the-beast.com gives a 404.
# paste.simplylinux.ch needs an API key
# paste.centos.org needs an API key
# Lots of others tested with issues...
#
# Other:
# pasta.cf was great but has been broken for ages.
