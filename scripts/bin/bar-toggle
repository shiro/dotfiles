#!/bin/zsh


if pgrep poly > /dev/null; then
  polybar-msg cmd show
else
  polybar main &
fi

sleep 3

polybar-msg cmd hide
