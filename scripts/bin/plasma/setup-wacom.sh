#!/bin/zsh

xrandr --fb 4480x2880 --output eDP --scale 1 --pos 0x1440

# downscale hdpi display
xrandr --fb 4480x2880 --output DisplayPort-0 --scale .65 --pos 1920x1440

# ask wacom to use the new display position
for device in "Touch Finger touch" "Pen stylus" "Pen eraser"; do
  xsetwacom set "Wacom Cintiq Pro 16 $device" MapToOutput "DisplayPort-0"
done
