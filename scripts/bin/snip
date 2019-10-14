#!/bin/zsh

[ $# -lt 1 ] && echo "missing destination parameter" && exit 1

# initialize enviorment
TEMPLATE_ROOT="$XDG_CONFIG_HOME/snip"

# initialize recipe enviorment
export DESTINATION="$1"


# make sure dependencies are installed
for app in jq vipe fzf j2; do
  command -v $app > /dev/null || { echo "$app must be installed" && exit 1 }
done


# init directories
if [ ! -d "$TEMPLATE_ROOT" ]; then
  mkdir -p $TEMPLATE_ROOT
fi


# handle snippet input
if [ -n "$2" ]; then
  if [ -f "$2" ] || [ -f "$TEMPLATE_ROOT/$2" ]; then
    export SNIPPET="$2"
  else
    echo "'$2': file not found"
    exit
  fi
fi


if [ -z "$SNIPPET" ]; then
  export SNIPPET="`find "$TEMPLATE_ROOT"/* -type f -not -name "*.json" -exec realpath --relative-to "$TEMPLATE_ROOT" {} \; | fzf`"
fi

export DATASOURCE="$SNIPPET"

# require valid snippet
[ -z "$SNIPPET" ] && echo "snippet was not defined but is required" && exit 0



assign(){
  [ $# -ne 2 ] && echo "assign: expected 2 arguments, but got $#" && exit 1
  local varName="$1"
  local value="$2"
  eval "unset $varName"

  # dark HEREDOC magic to assign multi-line value to variable
  eval 'read -d "" '"$varName"' <<EOF
'"$value"'
EOF'
  eval "export $varName"
  # eval "echo $varName \$$varName"
}

resolve(){
  [ $# -ne 1 ] && echo "resolve: expected 1 argument, but got $#" && exit 1

  if [ -f "$PWD/$1" ]; then
    echo "$PWD/$1"
  elif [ -f "$TEMPLATE_ROOT/$1" ] ;then
    echo "$TEMPLATE_ROOT/$1"
  else
    >&2 echo "'$1': file not found"
    exit 1
  fi
}

variables(){
  set -e
  [ $# -ne 1 ] && echo "load-data: expected 1 argument, but got $#" && exit 1

  # the file could be in several locations
  local file_location
  file_location="$(resolve "$1")"

  # calculate the json result from the source file
  local result='{}'

  local file_variables=(`grep -oP '(?<={{ )[^ ]+(?= }})' "$file_location" | sort -u`)

  for var in "${file_variables[@]}"; do
    result="`set-value "$result" "$var" ''`"
  done

  echo "$result"
}

edit(){
  [ $# -ne 1 ] && echo "edit: expected 1 argument, but got $#" && exit 1
  local data="$1"
  local outputVar="$2"

  echo "$data" | vipe
}

merge(){
  set -e
  [ $# -ne 2 ] && echo "merge: expected 2 arguments, but got $#" && exit 1
  local data1="$1"
  local data2="$2"

  echo "$data1" | jq ". + $data2"
}

set-value(){
  [ $# -ne 3 ] && echo "set-value: expected 3 arguments, but got $#" && exit 1
  local data="$1"
  local key="$2"
  local value="$3"

  merge "$data" "{\"$key\":\"$value\"}"
}

get-value(){
  [ $# -ne 2 ] && echo "get-value: expected 2 arguments, but got $#" && exit 1
  local data="$1"
  local key="$2"

  echo "$data" | jq -r ".$key"
}

render(){
  [ $# -lt 1 ] && echo "render: expected 1-2 arguments, but got $#" && exit 1

  local data="$2"

  # initialize data
  if [ -z "$data" ];then
    data=$(variables "$1")
    data=$(edit "$data")
  fi

  local snippet="$(resolve "$1")"

  if [ -n "$data" ]; then
    j2 --format=json "$snippet" <(echo "$data")
  else
    j2 "$snippet"
  fi
}


case "${SNIPPET:e}" in
  recipe)
    export PWD="$(realpath "$(dirname "$TEMPLATE_ROOT/$SNIPPET")")"

    (source "$TEMPLATE_ROOT/$SNIPPET")
    ;;
  *)
    set -e
    if [ -d "$DESTINATION" ]; then
     DESTINATION="$DESTINATION/${SNIPPET:t}"
    fi

    local data
    data=$(variables "$DATASOURCE")
    data=$(edit $data)

    render "$SNIPPET" "$data" > "$DESTINATION"
    ;;
esac

