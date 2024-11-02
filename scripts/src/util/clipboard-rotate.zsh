#!/usr/bin/env zsh

cliphist list | head -n2 | tail -n1 | cliphist decode | wl-copy
