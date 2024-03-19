#!/bin/sh

wrappers=()

if command -v snp &> /dev/null; then
  wrappers+=("snp")
fi

nice -n 18 $wrappers yay -Syu --devel
