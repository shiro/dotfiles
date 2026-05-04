#!/usr/bin/env zsh

pkill -f '/discord'

betterdiscordctl install
betterdiscordctl reinstall

discord &
sleep 10
pkill -f '/discord'

sleep 5

betterdiscordctl reinstall

discord
