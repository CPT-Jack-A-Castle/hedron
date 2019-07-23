#!/bin/bash

set -e

DIR=$(mktemp -d)

ID=$1

# 2048 is the default
BITS=2048

cd "$DIR"

echo -n | tincd -c "$DIR" -K "$BITS" 2> /dev/null

# There are newlines before the content on these files.
echo '          public: |'
sed 's/^/            /' "$DIR"/rsa_key.pub | tail -n +2

if [ -n "$ID" ]; then
    echo "{% if grains['id'] == '$ID' %}"
fi

echo '          private: |'
sed 's/^/            /' "$DIR"/rsa_key.priv | tail -n +2

if [ -n "$ID" ]; then
    echo "{% endif %}"
fi

rm -r "$DIR"
