# use hub instead of git, as it can do everything git can do, and more!
if command -v hub > /dev/null; then
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
ggo() {
  if [ $# -eq 1 ]; then
    local flag=$(git show-ref --verify --quiet refs/heads/"$1" && echo '' || echo '-b')
    git checkout $flag "$1"
  else
    git checkout "$@"
  fi
}
alias gbd='git branch -D'
alias gl='git log --oneline --decorate --graph'
alias gm='git merge'
alias gmt='git mergetool'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull'
alias gplf='git pull --force'
alias gr='git rebase'
alias gre='git reset'
alias greh='git reset --hard'
alias grm='git rm'
alias gs='git submodule'
alias gsa='git submodule add'
alias gsi='git submodule init'
alias gsd='git submodule deinit'
alias gsu='git submodule update'

# Append git index to a past commit
gapp() {
  if [ -z "$(git diff --cached --name-only)" ]; then
    echo "Git index is empty. Exiting."
    return
  fi

  # Get the commit hash to fix up using fzf
  local commit_hash=$(git log --oneline --no-merges $(git merge-base HEAD master)..HEAD | fzf | awk '{print $1}')
  
  if [ -z "$commit_hash" ]; then
    echo "No commit selected. Exiting."
    return
  fi

  # Create a fixup commit for the chosen commit hash
  git commit --fixup "$commit_hash"

  # Stash unstaged changes
  git stash

  # Rebase interactively and autosquash to apply the fixup
  git rebase --interactive --autosquash $(git merge-base HEAD master)

  # Restore unstaged changes
  git stash pop
}

# doge git
alias such=git
alias very=git
alias wow='git log --oneline --decorate --graph --all'
