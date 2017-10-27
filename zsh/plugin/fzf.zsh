# options
export FZF_DEFAULT_OPTS="--height 40% --reverse
  --color=prompt:#c0d5c1,pointer:#ce840d
  --color=fg:#c0d5c1,hl:#90c93f,hl+:#90c93f"


# auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/shiro/.fzf/shell/completion.zsh" 2> /dev/null

# key bindings
# ------------
source "/home/shiro/.fzf/shell/key-bindings.zsh"

