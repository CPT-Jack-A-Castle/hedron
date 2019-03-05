#!/bin/sh

set -e

mkdir build
cd build
cmake ..
# They don't have make install?
make
cp xmrig-amd /usr/local/bin
