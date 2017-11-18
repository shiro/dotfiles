# heavily inspired by the wonderful pure theme
# https://github.com/sindresorhus/pure

# needed to get things like current git branch
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git # You can add hg too if needed: `git hg`
zstyle ':vcs_info:git*' use-simple true
zstyle ':vcs_info:git*' max-exports 2
zstyle ':vcs_info:git*' formats ' %b' 'x%R'
zstyle ':vcs_info:git*' actionformats ' %b|%a' 'x%R'

autoload colors && colors


function prompt_git_info() {
  local ref
  ref=$(git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(git rev-parse --short HEAD 2> /dev/null) || return 0

  echo -n " on ${ref#refs/heads/}"

  command git diff --quiet --ignore-submodules HEAD &>/dev/null;
  if [[ $? -eq 1 ]]; then
      echo -n "%F{red}✗%f"
  else
      echo -n "%F{green}✔%f"
  fi


}


# indicate a job (for example, vim) has been backgrounded
# If there is a job in the background, display a ✱
suspended_jobs() {
    local sj
    sj=$(jobs 2>/dev/null | tail -n 1)
    if [[ $sj == "" ]]; then
        echo ""
    else
        echo "%{$FG[208]%}✱%f"
    fi
}

prompt_user() {
  echo -n "%{$Green%}"
  echo -n "%n"
  echo -n "%{$Color_Off%}"
}

prompt_pwd() {
  echo -n " at "
  echo -n "%{$Purple%}"
  echo -n "${PWD/#$HOME/~}"
  echo -n "%{$Color_Off%}"
}

prompt_token() {
  echo -n ' 兎'
  echo -n "%(?: :%{$Purple%}♭)"
  echo -n "%{$Color_Off%}"
}

build_prompt() {
  prompt_user
  prompt_pwd
  prompt_git_info
  prompt_token
}

setopt PROMPT_SUBST

# export PROMPT='%(?.%F{205}.%F{red})⇨%f '
# export RPROMPT=`git_dirty`%F{241}$vcs_info_msg_0_%f `git_arrows``suspended_jobs`
export PROMPT='`build_prompt`'
export RPROMPT=''

