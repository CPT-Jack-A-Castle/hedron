#!/bin/sh

set -e

./autogen.sh
# Disable tests for a faster build. Idealy, would run without that every so often
# to be sure it's still good.
./configure --with-incompatible-bdb --disable-tests
cd src/secp256k1
CC_FOR_BUILD=cc make
cd ../..

# Note that CXX      libbitcoin_server_a-init.o
# takes tons of memory. This build will likely need 2GiB of memory.
make install
