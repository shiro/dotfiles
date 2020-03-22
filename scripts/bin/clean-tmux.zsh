#!/bin/zsh


# filter detached sessions with default names
tmux list-sessions | grep -E '^[0-9]+:' | grep -E -v '\(attached\)' | while IFS='\n' read session; do
    tmux kill-session -t "${session%%:*}"
done
