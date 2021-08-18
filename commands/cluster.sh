#! /bin/bash

unset COMMAND
unset CLUSTER
unset VERSION

source "./lib/create.sh"
source "./lib/install.sh"
source "./lib/list.sh"
source "./lib/remove.sh"

function usage()
{
  cat "${PARENT_PATH}/usage/cluster"
  exit 1
}

COMMAND=$1; shift
PARSED_ARGUMENTS=$(getopt -a -n "escue cluster" -o o:i:f: --long version: -- "$@")
VALID_ARGUMENTS=$?
eval set -- "$PARSED_ARGUMENTS"


while : ; do
    case $1 in
      -f|--file   ) FILE=$2         ; shift 2 ;;
      -i          ) INDENTY_FILE=$2 ; shift 2 ;;
      -o          ) SSHOPTIONS=$2   ; shift 2 ;;
      --) shift; break ;;
      *)
        echo "Unexpected option: $1 - this should not happen."
        usage ;;
    esac
done



CLUSTER="$@"

[[ $VALID_ARGUMENTS != "0" ]] && usage
[[ -z $CLUSTER ]] && [[ $COMMAND != 'list' ]] && usage

case $COMMAND in
  create  ) create_cluster "${PARENT_PATH}/cluster/" "$CLUSTER" ;;
  install ) install_cluster $CLUSTER $FILE "$INDENTY_FILE" "$SSHOPTIONS" ;;
  restart ) restart_cluster $CLUSTER "$INDENTY_FILE" "$SSHOPTIONS";;
  remove  ) remove_cluster $CLUSTER "$INDENTY_FILE" "$SSHOPTIONS";;
  list    ) get_cluster_lst ;;
  -h|--help) usage ;;
  *);;
esac
