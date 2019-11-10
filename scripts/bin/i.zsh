#!/bin/zsh
#
# Check which packages are installed, matching the regex
#
# Arguments:
#   regex

yay -Qe | grep -P -- "$1"
