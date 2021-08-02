#! /bin/bash

unset COMMAND
unset CLUSTER

PARENT_PATH=$( cd "$(dirname "$0")" && cd .. || exit 1; pwd )
source "${PARENT_PATH}/lib/create.sh"

usage() {
  cat "${PARENT_PATH}/usage/node"
}

COMMAND=$1; shift

PARSED_ARGUMENTS=$(getopt -a -n "escue node" -o c: --long cluster: -- "$@")
VALID_ARGUMENTS=$?

eval set -- "$PARSED_ARGUMENTS"

while : ; do
    case $1 in
      -c|--cluster) CLUSTER=$2 ; shift 2 ;;
      --) shift; break ;;
      *)
        echo "Unexpected option: $1 - this should not happen."
        usage ;;
    esac
done


if [ $VALID_ARGUMENTS != "0" ]; then
  usage
fi

if [ -z $CLUSTER ]; then
  # CLUSTER parameter is required
  usage
fi

NODE="$@"

case $COMMAND in
  create)  createNode $CLUSTER $NODE  ;;
  change)  ;;
  install) installNode $CLUSTER $NODE ;;
  -h | --help) usage ;;
esac
