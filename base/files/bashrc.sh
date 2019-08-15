#!/bin/bash

# Caniblized from the original /etc/bash/bash.bashrc on a Debian 9 host.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

PS1='\u@\h:\w\$ '

export EDITOR='vi'
