#!/usr/bin/env bash

# getdate() {
#     date '+%Y-%m-%d_%H.%M.%S'
# }

# getaudiooutput() {
#     pactl list sources | grep 'Name' | grep 'monitor' | cut -d ' ' -f2
# }
#
# getactivemonitor() {
#     hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name'
# }

# mkdir -p "$(xdg-user-dir VIDEOS)"
# cd "$(xdg-user-dir VIDEOS)" || exit
if pgrep wf-recorder > /dev/null; then
    notify-send "Recording saved" -t 2000 &
    pkill wf-recorder &
else
    file="$HOME/Videos/screencaps/$(date +'%Y-%m-%d-%H%M%S.mp4')"
    mkdir -p "$(dirname "$file")"
    wf-recorder -g "$(slurp)" --file="$file"
    wl-copy < "$file"
    # if [[ "$1" == "--sound" ]]; then
    #     wf-recorder --pixel-format yuv420p -f './recording_'"$(getdate)"'.mp4' -t --geometry "$(slurp)" --audio="$(getaudiooutput)" & disown
    # elif [[ "$1" == "--fullscreen-sound" ]]; then
    #     wf-recorder -o $(getactivemonitor) --pixel-format yuv420p -f './recording_'"$(getdate)"'.mp4' -t --audio="$(getaudiooutput)" & disown
    # elif [[ "$1" == "--fullscreen" ]]; then
    #     wf-recorder -o $(getactivemonitor) --pixel-format yuv420p -f './recording_'"$(getdate)"'.mp4' -t & disown
    # else
    #     wf-recorder --pixel-format yuv420p -f './recording_'"$(getdate)"'.mp4' -t --geometry "$(slurp)" & disown
    # fi
fi
