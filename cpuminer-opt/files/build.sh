#!/bin/sh

set -e

cd /usr/local/src

git clone https://github.com/JayDDee/cpuminer-opt.git
cd cpuminer-opt
./build.sh
make install
