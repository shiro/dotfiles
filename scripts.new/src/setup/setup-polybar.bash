#!/bin/bash

killall polybar 2>/dev/null

# xrandr | grep -oP '((eDP|DisplayPort|HDMI)[^\s]*connected[^\s]*)' 

xrandr | grep -oP '(eDP|DisplayPort|HDMI)[^\s]*(?= +connected)'| xargs -P1 -I{} bash -c 'MONITOR={} polybar main &'
