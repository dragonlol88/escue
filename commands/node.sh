#! /bin/bash

unset COMMAND
unset CLUSTER
unset FILE
unset INDENTY_FILE

source "./lib/create.sh"
source "./lib/install.sh"
source "./lib/list.sh"
source "./config/globals"

function usage() {
  cat "./usage/node"
  exit 1
}

COMMAND=$1; shift
PARSED_ARGUMENTS=$(getopt -a -n "escue node" -o o:i:f:c: --long cluster:,file: -- "$@")
VALID_ARGUMENTS=$?
eval set -- "$PARSED_ARGUMENTS"

while : ; do
    case $1 in
      -c|--cluster) CLUSTER=$2      ; shift 2 ;;
      -f|--file   ) FILE=$2         ; shift 2 ;;
      -i          ) INDENTY_FILE=$2 ; shift 2 ;;
      -o          ) SSHOPTIONS=$2   ; shift 2 ;;
      --) shift; break ;;
      *)
        echo "Unexpected option: $1 - this should not happen."
        usage ;;
    esac
done


NODE="$@"

[[ $VALID_ARGUMENTS != "0" ]] && usage
[[ -z $CLUSTER ]] && [[ $COMMAND != 'list' ]] && usage   # CLUSTER parameter is required
[[ $COMMAND = 'install' ]] && [[ -z $FILE ]] && usage

case $COMMAND in
  create  )  create_node $CLUSTER $NODE  ;;
  change  )  ;;
  install ) install_node $CLUSTER $NODE $FILE "$INDENTY_FILE" "$SSHOPTIONS" ;;
  remove  ) remove_node  $CLUSTER $NODE "$INDENTY_FILE" "$SSHOPTIONS" ;;
  restart ) restart_node $CLUSTER $NODE "$INDENTY_FILE" "$SSHOPTIONS";;
  list) get_node_lst $CLUSTER ;;
  -h | --help) usage ;;
  *) usage ;;

esac
