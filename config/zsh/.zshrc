#!/bin/zsh


[ -d ~/bin ] && export PATH=~/bin:$PATH



# load zit, the plugin manager
source ${ZDOTDIR}/plugins/zit.zsh
export ZIT_MODULES_PATH="${HOME}/.local/share/zit-modules"

# enable 256 color terminal
[ -z "$TMUX" ] && export TERM=xterm-256color

# we need advanced globbing for this
configs=(
  ${ZDOTDIR}/*.zsh
  ${ZDOTDIR}/completion/*.zsh
  ${ZDOTDIR}/alias/*
  ${ZDOTDIR}/functions/*.zsh
  ${ZDOTDIR}/key-bindings/*.zsh
  ${ZDOTDIR}/plugins/*
)

# source all .zsh files inside of the zsh/ directory
for config in "${configs[@]}"; do
  source $config;
done


# additional plugins
zit-in "https://github.com/knu/zsh-manydots-magic" "zsh-manydots-magic"
zit-lo "zsh-manydots-magic" "manydots-magic"

zit-in "https://github.com/m45t3r/zit" "zit"

# zit-in "https://github.com/zsh-vi-more/evil-registers" "zsh-vim-register"
zit-in "https://github.com/kutsan/zsh-system-clipboard" "zsh-system-clipboard"
zit-lo "zsh-system-clipboard" "zsh-system-clipboard.zsh"


zit-in "https://github.com/Vifon/zranger" "zranger"
export fpath=($fpath "$ZIT_MODULES_PATH/zranger")
autoload -U zranger


# load local settings
[ -f "$LOCAL_CONFIG_DIR/zsh/zshrc" ] && source "$LOCAL_CONFIG_DIR/zsh/zshrc"
[ -f "$LOCAL_CONFIG_DIR/zsh/alias" ] && source "$LOCAL_CONFIG_DIR/zsh/alias"


# compile everything so it loads faster
[ -z $ZSH_NO_COMPILE ] && zit-lo "zit" "extras/compile-zsh-files.zsh"


if [ -f "$HOME/.local/config/nix/nix-shell-locations" ]; then
  typeset -A locations
  while IFS= read -r line; do
    locations["$line"]=1
  done < "$HOME/.local/config/nix/nix-shell-locations"

  autoload -U add-zsh-hook
  __auto_nix_shell() {
    if [[ "$AUTO_INIT_NIX_SHELL" == 1 ]]; then
      return
    fi

    if [ -n "$locations["`pwd`"]" ]; then
      if command -v cached-nix-shell > /dev/null; then
        AUTO_INIT_NIX_SHELL=1 cached-nix-shell --command zsh
      else
        AUTO_INIT_NIX_SHELL=1 nix-shell --command zsh
      fi
    fi
  }
  add-zsh-hook chpwd __auto_nix_shell

  # call it initially as well
  __auto_nix_shell
fi


if [[ $1 == eval ]]
then
    "$@"
set --
fi
