alias glNoGraph='git log --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr% C(auto)%an" "$@"'
local _gitLogLineToHash="echo {} | grep -o '[a-f0-9]\{7\}' | head -1"
local _viewGitLogLine="$_gitLogLineToHash | xargs -I % sh -c 'git show --color=always %'"
local _gitDiffLineToFilename="echo {} | cut -c4-"
local _viewGitDiffLine="$_gitDiffLineToFilename | xargs -I % sh -c 'git diff --color=always -- %'"


is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

# diff modfied files against HEAD
gdd() {
  is_in_git_repo || return

  git -c color.status=always status --short |
  fzf --no-sort --reverse --tiebreak=index --no-multi --ansi \
    --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500' \
    --bind "enter:execute:$_viewGitDiffLine | less -R"
}

fgb() {
  is_in_git_repo || return
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf-down --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -'$LINES |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##'
}

# fcoc_preview - checkout git commit with previews
fco() {
  local commit
  commit=$( glNoGraph |
    fzf --no-sort --reverse --tiebreak=index --no-multi \
        --ansi --preview $_viewGitLogLine ) &&
  git checkout $(echo "$commit" | sed "s/ .*//")
}


# fzf checkout git branch (including remote branches)
fbr() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
  tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# git commit browser
fgs() {
  glNoGraph |
  fzf --no-sort --reverse --tiebreak=index --no-multi \
    --ansi --preview $_viewGitLogLine \
    --bind "enter:execute:$_viewGitLogLine   | less -R" \
    --bind "ctrl-y:execute:$_gitLogLineToHash | xsel"
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
