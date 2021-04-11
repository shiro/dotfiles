#!/bin/zsh

systemctl --user restart pulseaudio.socket
systemctl --user restart pulseaudio.service

killall -9 cadence carla non-mixer /usr/bin/jack-autoconnect
pulseaudio --kill

cadence-session-start -s

(
  # mixer
  non-mixer ~/audio/mixer &


  ( /usr/bin/jack-autoconnect ) &

  sleep 5;

  # plugin host
  carla ~/audio/carla-system.carxp &
) &

sleep 2

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

# workaround for cadence not exposing pulse sink settings (https://github.com/falkTX/Cadence/issues/234)
jack_disconnect "PulseAudio JACK Sink:front-left" "system:playback_1"
jack_disconnect "PulseAudio JACK Sink:front-right" "system:playback_2"

(alsa_out -j "hdmi-1" -d hw:0,3) &

# discord=$(pgrep -l discord | cut -d' ' -f2)
