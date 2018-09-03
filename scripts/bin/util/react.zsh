#!/bin/zsh


SCRIPT_NAME="`basename $0`"

usage(){
  cat <<USAGE
  Usage: $SCRIPT_NAME [OPTION]...
    -o=<REPO_PATH>  backup to REPO_PATH
        --help      print this message
USAGE
}


while getopts :c:o:-: opt; do
  case "$opt" in
    # c)
    #   if [ ! -f "$OPTARG" ]; then
    #   ;;
    -) case "$OPTARG" in
        help)
          usage; exit 0
          ;;
        *)
          usage; exit 1
          ;;
      esac;;
    :|\?)
      usage; exit 1
      ;;
  esac
done
shift $((OPTIND-1))


# no additional arguments
[ $# -eq 0 ] && usage && exit 1

# templates {{{

read -r -d '' SFC_TEMPLATE <<'TEMPLATE'
import * as React from "react";

import * as css from "./$[NAME].scss";


interface IProps {
    className?: {
        element: string;
    };
}

const $[NAME]: React.SFC<IProps> = (props) => {
    const className = props.className || {};

    return (
        <div className={className.element}>
            {props.children}
        </div>
    );
}

export default $[NAME];

TEMPLATE

read -r -d '' COMPONENT_TEMPLATE <<'TEMPLATE'
import * as React from "react";
import classNames from 'classnames';

import * as css from "./$[NAME].scss";


interface IProps {
    className?: string;
}

interface IState {
}

export class $[NAME] extends React.Component<IProps, IState> {
    state : IState = {
    }

    constructor(props){
        super(props);
    }

    componentDidMount(){

    }

    componentDidUpdate(props, state, snapshot){

    }

    componentWillUnmount(){

    }

    render() {
        return <div className={this.props.className}>
            {this.props.children}
        </div>
    }
}

export default $[NAME];
TEMPLATE

# }}}

case "${1:l}" in
  com*) # component
    local component_name="$2"
    local dest="$3"

    [ -z $component_name ] && usage && exit 1
    [ ! -d "$dest" ] && usage && exit 1

    echo $COMPONENT_TEMPLATE | sed \
      -e 's/\$\[NAME\]/'"$component_name/g" \
      > "$dest/$component_name.tsx"
    touch  "$dest/$component_name.scss"

    shift 2
    ;;
  sfc) # sfc
    local component_name="$2"
    local dest="$3"

    [ -z $component_name ] && usage && exit 1
    [ ! -d "$dest" ] && usage && exit 1

    echo $SFC_TEMPLATE | sed \
      -e 's/\$\[NAME\]/'"$component_name/g" \
      > "$dest/$component_name.tsx"
    touch  "$dest/$component_name.scss"
    shift 2
    ;;
  *)
    usage; exit 1
    ;;
esac
