#!/bin/zsh

# xrandr --output eDP --scale 1 --pos 0x1440 --primary

# primary_w=1920
# primary_h=1080

# hdpi_w=2560
# hdpi_h=1440
# downscale hdpi display
# xrandr --fb 4480x2880 --output DisplayPort-0 --scale 1.2 --pos 1920x1440
# set +e
# xrandr --fb 3500x2520 --output DisplayPort-0 --scale 1.2 --pos 1920x1440 2>/dev/null
# sleep 5
# xrandr --fb 4180x2880

# xrandr --newmode 1160x568 52.13  1160 1200 1320 1480  568 569 572 588  -HSync +Vsync

# xrandr --newmode osu $(cvt 1160 568 | tail -n1 | sed -r 's/Modeline [^ ]+ *//') 2>/dev/null
# xrandr --addmode DisplayPort-0 1160x568_59.90
# xrandr --output DisplayPort-0 --fb 1160x568 --panning 1160x568 --mode 1160x568_59.90
# xrandr --fb 4480x2880 --output DisplayPort-0 --mode 1280x800

# xrandr --addmode DisplayPort-0 osu
# xrandr --output DisplayPort-0 --mode osu --scale 2 # --pos 1920x1440 #--scale-from 2560x1440

# xrandr --addmode DisplayPort-0 1160x568
# xrandr --output DisplayPort-0 --mode 1160x568
# xrandr --fb 4380x2520




# xrandr --fb 4480x2880
# xrandr --fb 4380x2520 2>/dev/null

# sleep 7
# xrandr --output DisplayPort-0 --scale 1 --pos 1920x1440

# xsetwacom set "Wacom Cintiq Pro 16 Pen stylus" MapToOutput 1920x1080+0+1440



devices="$(xsetwacom --list devices | sed 's/id:.*//')"

while read device; do
  # echo $device
  # echo
  xsetwacom set "$device" MapToOutput 1920x1080+0+0
  xsetwacom set "$device" Area 0 15000 8000 19000
  xsetwacom set "$device" Touch off
  # xsetwacom set "$device" ResetArea
done < <(echo "$devices")

