alias md='mkdir -p'
mcd(){ mkdir -p $1 && cd $_ }

alias rd=rmdir

# List directory contents
alias lsa='ls -lah --color'
alias l='ls -lah --color'
alias ll='ls -lh --color'
alias la='ls -lAh --color'

# ranger
alias r=ranger

# fzf through directory stack
d(){ eval cd $(dirs -v | sed -r 's/^[0-9]+	//' | fzf) }

