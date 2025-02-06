#!/usr/bin/env zsh

cliphist list | head -n1 | cliphist delete
cliphist list | head -n1 | cliphist decode | wl-copy
