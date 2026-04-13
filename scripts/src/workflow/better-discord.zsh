#!/usr/bin/env zsh

pkill -9 discord

betterdiscordctl install
betterdiscordctl reinstall

discord &
sleep 30
pkill -9 discord

betterdiscordctl reinstall

discord
