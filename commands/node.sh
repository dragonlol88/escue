#! /bin/bash

unset COMMAND
unset CLUSTER
unset FILE
unset INDENTY_FILE
PARENT_PATH=$( cd "$(dirname "$0")" && cd .. || exit 1; pwd )
source "${PARENT_PATH}/lib/create.sh"
source "${PARENT_PATH}/lib/install.sh"
source "${PARENT_PATH}/lib/list.sh"
function usage() {
  cat "${PARENT_PATH}/usage/node"
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


if [ $VALID_ARGUMENTS != "0" ]; then
  usage
fi

if [ -z $CLUSTER ] && [ $COMMAND != 'list' ]; then
  # CLUSTER parameter is required
  usage
fi

if [ $COMMAND = 'install' ] && [ -z $FILE ]; then
  usage
fi

NODE="$@"

case $COMMAND in
  create)  create_node $CLUSTER $NODE  ;;
  change)  ;;
  install)
    install_node $CLUSTER $NODE $FILE $INDENTY_FILE $SSHOPTIONS ;;
  list) get_node_lst $CLUSTER ;;
  -h | --help) usage ;;
  *) usage ;;

esac
