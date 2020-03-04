#!/bin/zsh

#xrandr --fb 4480x2880 --output eDP --scale 1 --pos 0x1440 --primary

# set monitor 2 resolution
#xrandr --fb 4480x2880 --output DisplayPort-0 --mode 1920x1080 --scale 1 --pos 1920x1440

xrandr --output DisplayPort-1 --pos 0x0


# downscale hdpi display (not working right now)
# xrandr --fb 4480x2880 --output DisplayPort-0 --scale .65 --pos 1920x1440

# ask wacom to use the new display position

devices="$(xsetwacom --list devices | sed 's/id:.*//')"

while read device; do
  xsetwacom set "$device" ResetArea
  xsetwacom set "$device" MapToOutput "DisplayPort-0"

  xsetwacom set "$device" Touch on
  xsetwacom set "$device" Gesture off
done < <(echo "$devices")
