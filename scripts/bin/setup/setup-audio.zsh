#!/bin/zsh

killall cadence carla non-mixer pulseaudio

cadence-session-start -s

(
  # mixer
  non-mixer ~/audio/mixer &


  ( /usr/bin/jack-autoconnect ) &

  sleep 5;

  # plugin host
  carla ~/audio/carla-system.carxp &
) &

# communication
pactl load-module module-jack-sink   client_name=comm-out connect=no
pactl load-module module-jack-source client_name=comm-in  connect=no

# browser
pactl load-module module-jack-sink   client_name=browser_out connect=no

# music
pactl load-module module-jack-sink   client_name=music_out connect=no

# general use busses
pactl load-module module-jack-sink   client_name=gen1_out connect=no
pactl load-module module-jack-sink   client_name=gen2_out connect=no
pactl load-module module-jack-sink   client_name=gen3_out connect=no
