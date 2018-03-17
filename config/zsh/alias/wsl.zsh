if [[ "$KERNEL_TYPE" != *Microsoft ]]; then

  alias open='cmd.exe /c start "$1"'

  # explorer commands
  ex(){ explorer /e,"$(wslpath -w "$(realpath "$1")")" }
  exrc(){ ex ${ZDOTDIR}/alias }

fi
