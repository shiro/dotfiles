# advanced ga(c) ** completion
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

# g is git
compdef g=git
compdef _git ga=git-add
compdef _git gac=git-add
compdef _git gacp=git-add
