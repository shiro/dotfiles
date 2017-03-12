# options
export FZF_DEFAULT_OPTS='--height 40% --reverse --bind alt-j:down,alt-k:up'


# auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/shiro/.fzf/shell/completion.zsh" 2> /dev/null

# key bindings
# ------------
source "/home/shiro/.fzf/shell/key-bindings.zsh"

