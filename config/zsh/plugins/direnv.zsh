#!/usr/bin/env zsh

nclr () { local j; for ((j = 0; j <= "${1:-1}"; j++ )); do tput cuu1; done; tput ed; }

if [ -f "$HOME/.local/config/nix/nix-shell-locations" ]; then
  typeset -A locations
  while IFS= read -r line; do
    locations["$line"]=1
  done < "$HOME/.local/config/nix/nix-shell-locations"

  autoload -U add-zsh-hook
  __auto_nix_shell() {
    [[ "$AUTO_INIT_NIX_SHELL_DONE" == 1 ]] && return 0
    [[ "$TMP" == /tmp/nix-shell-* ]] && return 0

    local ignored_commands=(disable-auto-shell cd echo export s proj r rm dot ls la g ga gac gam gd gf gp gpf gcp gpl gr gre gl ggo)
    local command=("${1// */}")

    # don't do anyting if command should be ignored
    (($ignored_commands[(Ie)$command])) && return 0

    # don't do anything for auto-cd (a lone directory path like `..` or `../foo`)
    if [[ "$1" != *' '* ]] && ! whence -- "$command" > /dev/null; then
      local target=${~command}
      [[ -d "$target" ]] && return 0
    fi

    # search upwards from the current directory for a registered location with a shell.nix
    local dir="$PWD" shell_file=
    while :; do
      if [ -n "$locations["$dir"]" ]; then
        if [ -f "$dir/shell.nix" ]; then
          shell_file="$dir/shell.nix"
          break
        elif [ -f "$dir/default.nix" ]; then
          shell_file="$dir/default.nix"
          break
        fi
      fi
      [[ "$dir" == / ]] && break
      dir="${dir:h}"
    done

    if [ -n "$shell_file" ]; then
      # echo initializing nix shell...
      # echo

      local shell_cmd=(nix-shell)

      if command -v cached-nix-shell > /dev/null; then
	shell_cmd=(cached-nix-shell -d)
      fi

      # cached nix shells sometimes don't create TMP...
      AUTO_INIT_NIX_SHELL_DONE=1 "${shell_cmd[@]}" "$shell_file" --command "zsh -is eval 'mkdir -p \$TMP; nclr && $1'"
    fi
    return 0
  }
  add-zsh-hook preexec __auto_nix_shell
fi

alias disable-auto-shell='export AUTO_INIT_NIX_SHELL_DONE=1'

# 's skip' disables the auto nix shell for this session; everything else goes to the s script
s() {
  if [[ "$1" == skip ]]; then
    export AUTO_INIT_NIX_SHELL_DONE=1
  else
    command s "$@"
  fi
}
