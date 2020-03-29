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
    local output="$(autojump ${@})" 
    if [[ -d "${output}" ]]; then
    	if [ -t 1 ]; then
    		echo -e "\\033[31m${output}\\033[0m"
    	else
    		echo -e "${output}"
    	fi
    	cd "${output}"
    elif [ -f "$output" ]; then
      XDG_CURRENT_DESKTOP=X-Generic xdg-open "$output"
    else
    	echo "autojump: directory '${@}' not found"
    	echo "\n${output}\n"
    	echo "Try \`autojump --help\` for more information."
    	false
    fi
  }
fi
