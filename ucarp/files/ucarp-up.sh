#!/bin/sh

set -e

INTERFACE=$1
IP=$2

/sbin/ip a a "$IP" dev "$INTERFACE"
