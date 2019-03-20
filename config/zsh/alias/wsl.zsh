if [[ "$KERNEL_TYPE" == *Microsoft ]]; then

  alias open='cmd.exe /c start "$1"'

  ex(){ explorer.exe ${1:-.}}

fi
