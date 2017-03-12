alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'

alias md='mkdir -p'
alias mdc='mkdir -p && cd $_' # md and go there
alias rd=rmdir

# List directory contents
alias lsa='ls -lah'
alias l='ls -lah'
alias ll='ls -lh'
alias la='ls -lAh'

# fzf through directory stack
d(){ eval cd $(dirs -v | sed -r 's/^[0-9]+	//' | fzf) }
