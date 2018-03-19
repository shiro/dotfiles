_fzf_complete_ga() {
  _fzf_complete "--multi --tac --sort \
    -m --ansi --nth 2..,.. --height 100% \
    --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500'" \
	"$@" < <(
	  echo "$(git diff --name-only)"
    )
}

_fzf_complete_gac() {
  _fzf_complete_ga
}

# custom comp defs
compdef g=git
compdef _git ga=git-add
compdef _git gac=git-add
compdef _git gacp=git-add
compdef _git gb=git-branch
compdef _git ggo=git-checkout
compdef _git gf=git-fetch
compdef _git gl=git-log
compdef _git gm=git-merge
compdef _git gpl=git-pull
compdef _git gp=git-push
compdef _git gr=git-rebase
compdef _git gre greh=git-reset
compdef _git grm=git-rm
