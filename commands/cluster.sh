#! /bin/bash

unset COMMAND
unset CLUSTER
unset VERSION


PARENT_PATH=$( cd "$(dirname "$0")" && cd .. || exit 1; pwd )
source "${PARENT_PATH}/lib/create.sh"
source "${PARENT_PATH}/lib/install.sh"
function usage()
{
  cat "${PARENT_PATH}/usage/cluster"
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

if [ $VALID_ARGUMENTS != "0" ]; then
  usage
fi

if [ -z $CLUSTER ]; then
  usage
fi


case $COMMAND in
  create ) create_cluster "${PARENT_PATH}/cluster/" "$CLUSTER" ;;
  install) install_cluster $CLUSTER $FILE $INDENTY_FILE $SSHOPTIONS ;;
  list   ) get;;
  change)  ;;
  -h|--help) usage ;;
  *)
    ;;

esac
