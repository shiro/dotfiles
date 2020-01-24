#!/bin/zsh

killall cadence carla non-mixer

cadence-session-start -s

(
  # mixer
  non-mixer ~/audio/mixer &

  sleep 5;

  # plugin host
  carla ~/audio/example1.carxp &
) &

# communication
pactl load-module module-jack-sink   client_name=comm-out connect=no
pactl load-module module-jack-source client_name=comm-in  connect=no

# browser
pactl load-module module-jack-sink   client_name=browser_out connect=no

# foobar
pactl load-module module-jack-sink   client_name=foobar_out connect=no

# general use busses
pactl load-module module-jack-sink   client_name=gen1_out connect=no
pactl load-module module-jack-sink   client_name=gen2_out connect=no
pactl load-module module-jack-sink   client_name=gen3_out connect=no