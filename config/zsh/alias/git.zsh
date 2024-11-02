# use hub instead of git, as it can do everything git can do, and more!
if command -v hub; then
  alias git='hub'
fi



ga(){ [[ $# -eq 0 ]] && git add -A || git add "$@" } # git add
gac(){ ga "$@" && git commit } # git add commit
gam(){ ga "$@" && git commit --amend --no-edit } # git add amend
gacp(){ gac "$@" && git push } # git add commit push
alias gb='git branch'
alias gc='git commit'
alias gcl='git clean'
alias gcp='git cherry-pick'
alias gd='git diff'
alias gdt='git difftool'
alias gf='git fetch'
alias gfp='git fetch && git pull'
alias ggo='git checkout'
alias gl='git log --oneline --decorate --graph'
alias gm='git merge'
alias gmt='git mergetool'
alias gp='git push'
alias gpl='git pull'
alias gr='git rebase'
alias gre='git reset'
alias greh='git reset --hard'
alias grm='git rm'
alias gs='git submodule'
alias gsa='git submodule add'
alias gsi='git submodule init'
alias gsd='git submodule deinit'
alias gsu='git submodule update'

# doge git
alias such=git
alias very=git
alias wow='git log --oneline --decorate --graph --all'
