#! /bin/bash

unset COMMAND
unset CLUSTER
unset FILE
unset INDENTY_FILE
unset CONFIG


PARENT_PATH=$( cd "$(dirname "$0")" && cd .. || exit 1; pwd )
lib_path=$PARENT_PATH/lib
libraries=($(ls $lib_path))
for library in "${libraries[@]}"; do source $lib_path/$library; done
source "${PARENT_PATH}/config/globals"

function usage() {
  cat "${PARENT_PATH}/docs/node"
  exit 1
}

COMMAND=$1; shift
PARSED_ARGUMENTS=$(getopt -a -n "escue node" -o o:i:s:c: --long cluster:,source:,config: -- "$@")
VALID_ARGUMENTS=$?
eval set -- "$PARSED_ARGUMENTS"

while : ; do
    case $1 in
      -c|--cluster ) CLUSTER=$2      ; shift 2 ;;
      -s|--source  ) SOURCE=$2         ; shift 2 ;;
      --config     ) CONFIG=$2       ; shift 2 ;;
      -i           ) INDENTY_FILE=$2 ; shift 2 ;;
      -o           ) SSHOPTIONS=$2   ; shift 2 ;;
      --) shift; break ;;
      *)
        echo "Unexpected option: $1 - this should not happen."
        usage ;;
    esac
done


NODE="$@"

[[ $VALID_ARGUMENTS != "0" ]] && usage
[[ -z $CLUSTER ]] && [[ $COMMAND != 'list' ]] && usage   # CLUSTER parameter is required
[[ $COMMAND = 'install' ]] && [[ -z $SOURCE ]] && usage

case $COMMAND in
  create  ) create_node   $CLUSTER $NODE  ;;
  mod     ) change_config $CLUSTER $NODE $CONFIG;;
  install ) install_node  $CLUSTER $NODE $SOURCE "$INDENTY_FILE" "$SSHOPTIONS" ;;
  remove  ) remove_node   $CLUSTER $NODE "$INDENTY_FILE" "$SSHOPTIONS" ;;
  restart ) restart_node  $CLUSTER $NODE "$INDENTY_FILE" "$SSHOPTIONS";;
  list    ) get_node_lst  $CLUSTER ;;
  -h | --help) usage ;;
  *) usage ;;
esac
