# Make sure that the terminal is in application mode when zle is active, since
# only then values from $terminfo are valid
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
  function zle-line-init() {
    echoti smkx
  }
  function zle-line-finish() {
    echoti rmkx
  }
  zle -N zle-line-init
  zle -N zle-line-finish
fi



bindkey -v  # use vim key bindings

export KEYTIMEOUT=1  # delay after esc

bindkey -M viins 'jj' vi-cmd-mode  # map jj to ESC

# if [[ "${terminfo[kpp]}" != "" ]]; then
#   bindkey "${terminfo[kpp]}" up-line-or-history  # [PageUp] - up a line of history
# fi
# if [[ "${terminfo[knp]}" != "" ]]; then
#   bindkey "${terminfo[knp]}" down-line-or-history  # [PageDown] - down a line of history
# fi


bindkey ' ' magic-space  # [Space] - do history expansion

if [[ "${terminfo[kcbt]}" != "" ]]; then
  bindkey "${terminfo[kcbt]}" reverse-menu-complete  # [Shift-Tab] - move through the completion menu backwards
fi


if [[ "${terminfo[kdch1]}" != "" ]]; then bindkey "${terminfo[kdch1]}" delete-char  # [Delete] - delete forward
else
  bindkey "^[[3~" delete-char
  bindkey "^[3;5~" delete-char
  bindkey "\e[3~" delete-char
fi

# Edit the current command line in $EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'q' edit-command-line


# history navigation
# autoload -U up-line-or-beginning-search
# autoload -U down-line-or-beginning-search
# zle -N up-line-or-beginning-search
# zle -N down-line-or-beginning-search

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd '^[[A' history-substring-search-up
bindkey -M vicmd '^[[B' history-substring-search-down


# file rename magic
bindkey "^[m" copy-prev-shell-word

# reset terminal with ease
reset_widget() { tput reset; builtin zle .redisplay; }
zle -N reset_widget
bindkey "^y" reset_widget
bindkey -M vicmd "^y" reset_widget
