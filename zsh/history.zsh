## Command history configuration

HISTFILE=~/.local/share/misc/.zsh_history


HISTSIZE=10000
SAVEHIST=10000

# Show history
case $HIST_STAMPS in
  "mm/dd/yyyy") alias history='fc -fl 1' ;;
  "dd.mm.yyyy") alias history='fc -El 1' ;;
  "yyyy-mm-dd") alias history='fc -il 1' ;;
  *) alias history='fc -l 1' ;;
esac

# setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS # ignore duplication command history list
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
# setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY # share command history data
setopt INC_APPEND_HISTORY # in realtime

# maintain directory stack
setopt AUTO_PUSHD # history stack
setopt PUSHD_IGNORE_DUPS # ignore duplicates in stack
setopt PUSHD_SILENT # be quiet about it

# Grep in history
function greph () { history 0 | grep -i $1 }
