#!/bin/sh

set -e

INTERFACE=$1
IP=$2

/sbin/ip a d "$IP" dev "$INTERFACE"
