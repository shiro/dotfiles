#!/usr/bin/env bash


. "${HOME}/.cache/wal/colors.sh"

reload_dunst() {
    pkill dunst
    dunst \
	-frame_width 0 \
        -lb "${color1}" \
        -nb "${color1}" \
        -cb "${color1}" \
        -lf "${color7}" \
        -bf "${color7}" \
        -cf "${color7}" \
        -nf "${color7}" &
}

reload_dunst
