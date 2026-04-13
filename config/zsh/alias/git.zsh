# use hub instead of git, as it can do everything git can do, and more!
if command -v hub > /dev/null; then
  alias git='hub'
fi



ga(){ [[ $# -eq 0 ]] && git add -A || git add "$@" } # git add
gac(){ ga "$@" && git commit } # git add commit
gaca(){ ga "$@" && git commit --amend } # git add commit amend
gacan(){ ga "$@" && git commit --amend --no-edit } # git add commit amend no edit
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
    # Check if remote branch exists first
    if git show-ref --verify --quiet refs/remotes/origin/"$1"; then
      # Remote branch exists, check it out and track it
      git checkout -b "$1" "origin/$1" 2>/dev/null || git checkout "$1"
    else
      # No remote branch, check if local branch exists
      local flag=$(git show-ref --verify --quiet refs/heads/"$1" && echo '' || echo '-b')
      git checkout $flag "$1"
    fi
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
# Rebase branch interactive
alias grb='git rebase -i $(git merge-base HEAD $(git symbolic-ref refs/remotes/origin/HEAD | sed "s@^refs/remotes/origin/@@"))'

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

# Edit commit
ge() {
  export COMMIT_HASH="${1:-$(git log --oneline --decorate | fzf --ansi --preview 'git show --color=always --decorate=short {1}' --color=fg:-1,hl:red:italic | awk '{print $1}')}"

  if [ -z "$COMMIT_HASH" ]; then
    echo "No commit hash specified. Exiting."
    return
  fi

  # Start a non-interactive rebase and edit the specified commit
  GIT_SEQUENCE_EDITOR="sed -i 's/^pick $COMMIT_HASH/edit $COMMIT_HASH/'" git rebase --interactive --autostash "$COMMIT_HASH^"
  git reset "HEAD^"

  export COMMIT_MESSAGE=$(git log -1 --pretty=%B $COMMIT_HASH)
}

# Commit edit
gec() {
  if [ -n "$(git status --porcelain)" ]; then
    git add .
    git commit -m "$COMMIT_MESSAGE"
  fi
  git rebase --continue
}

# Split commit
ges() {
  git add .
  git commit -m "$COMMIT_MESSAGE"
  git checkout "$COMMIT_HASH" .
  git reset
  export COMMIT_MESSAGE="[split]: $COMMIT_MESSAGE"
}

# doge git
alias such=git
alias very=git
alias wow='git log --oneline --decorate --graph --all'
