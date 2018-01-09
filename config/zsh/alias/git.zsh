# use hub instead of git, as it can do everything git can do, and more!
alias git='hub'

# fzf checkout git branch (including remote branches)
fbr() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# git commit browser
fshow() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}

# checkout git commit
fco() {
  local commits commit
  commits=$(git log --pretty=oneline --abbrev-commit --reverse) &&
  commit=$(echo "$commits" | fzf --tac +s +m -e) &&
  git checkout $(echo "$commit" | sed "s/ .*//")
}

# No arguments: `git status`
# With arguments: acts like `git`
g() {
  if [[ $# > 0 ]]; then
    git $@
  else
    git status -s
  fi
}
compdef g=git


ga(){ [[ $# -eq 0 ]] && git add -A || git add "$@" } # git add
gac(){ ga "$@" && git commit } # git add commit
gacp(){ gac "$@" && git push } # git add commit push
alias gb='git branch'
alias gc='git commit'
alias gcl='git clean'
alias ggo='git checkout'
alias gcp='git cherry-pick'
alias gd='git diff'
alias gdt='git difftool'
alias gf='git fetch'
alias gfp='git fetch && git pull'
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
alias gsi='git submodule init'
alias gsa='git submodule add'
alias gsd='git submodule deinit'
alias gsu='git submodule update'
