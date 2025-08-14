#!/usr/bin/env zsh

nclr () { local j; for ((j = 0; j <= "${1:-1}"; j++ )); do tput cuu1; done; tput ed; }

if [ -f "$HOME/.local/config/nix/nix-shell-locations" ]; then
  typeset -A locations
  while IFS= read -r line; do
    locations["$line"]=1
  done < "$HOME/.local/config/nix/nix-shell-locations"

  autoload -U add-zsh-hook
  __auto_nix_shell() {
    [[ "$AUTO_INIT_NIX_SHELL" == 1 ]] && return 0

    local ignored_commands=(cd proj r rm dot ls la g ga gac gam gd gf gp gcp gpl gr gre gl ggo)
    local command=("${1// */}")

    # don't do anyting if command should be ignored
    (($ignored_commands[(Ie)$command])) && return 0

    if [ -n "$locations["`pwd`"]" ]; then
      echo initializing nix shell...
      echo

      local shell_cmd=""
      if command -v cached-nix-shell > /dev/null; then
	shell_cmd="cached-nix-shell"
      else
	shell_cmd="nix-shell"
      fi
      AUTO_INIT_NIX_SHELL=1 $shell_cmd --command "zsh -is eval 'nclr && $1'"
    fi
    return 0
  }
  add-zsh-hook preexec __auto_nix_shell
fi
