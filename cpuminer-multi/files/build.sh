#!/bin/sh

set -e

cd /usr/local/src

git clone https://github.com/nicehash/cpuminer-multi.git
cd cpuminer-multi
./build.sh
make install
