#!/bin/zsh

if [ -f /etc/profile.d/autojump.zsh ]; then
  source /etc/profile.d/autojump.zsh

  # fzf integration
  # j(){
  #   [[ -n "$@" ]] && query="-q $@"

  #   cd "$(cat ~/.local/share/autojump/autojump.txt | sort -nr | awk -F "\\t" "{print \$NF}" | fzf +s $query )"
  # }
  j() {
    if [[ ${1} == -* ]] && [[ ${1} != "--" ]]; then
    	autojump ${@}
    	return
    fi
    setopt localoptions noautonamedirs

    [[ -n "$@" ]] && query="-q $@"
    local output="$(cat ~/.local/share/autojump/autojump.txt | sort -nr | awk -F "\\t" "{print \$NF}" | fzf +s $query)"
    if [[ -d "${output}" ]]; then
    	if [ -t 1 ]; then
    		echo -e "\\033[31m${output}\\033[0m"
    	else
    		echo -e "${output}"
    	fi
    	cd "${output}"
    elif [ -f "$output" ]; then
      # hacky way of determining whether a file should be openend in the terminal or GUI
      desktop_location="$(find-desktop-for-mime "$output")"

      if grep '^Terminal=true' "$desktop_location" > /dev/null 2>&1; then
         XDG_CURRENT_DESKTOP=X-Generic xdg-open "$output"
         return 0
      fi

      (xdg-open "$output" > /dev/null 2>&1 & 2>/dev/null disown)
    else
      return 1
    fi
  }
fi
