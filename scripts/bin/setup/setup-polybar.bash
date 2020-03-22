#!/bin/bash

killall polybar 2>/dev/null

xrandr | grep -oP '((eDP|DisplayPort)[^\s]*)' | xargs -P1 -I{} bash -c 'MONITOR={} polybar main &'
