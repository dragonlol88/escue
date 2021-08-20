#! /bin/bash

unset COMMAND

unset CLUSTER
unset FILE
unset INDENTY_FILE
unset TARGET
unset NODE
unset ELASTIC_JVM
unset ELASTIC_YML

PARENT_PATH=$( cd "$(dirname "$0")" && cd .. || exit 1; pwd )

source "${PARENT_PATH}/lib/sync.sh"

function usage() {
  cat "${PARENT_PATH}/usage/sync"
  exit 1
}

COMMAND=$1; shift

PARSED_ARGUMENTS=$(getopt -a -n "escue sync" -o aejo:i:s:n:t: --long source:,node:,target: -- "$@")
VALID_ARGUMENTS=$?

eval set -- "$PARSED_ARGUMENTS"

while : ; do
    case $1 in
      -s|--source   ) SOURCE=$2       ; shift 2 ;;
      -t|--target   ) TARGET=$2       ; shift 2 ;;
      -i            ) INDENTY_FILE=$2 ; shift 2 ;;
      -o            ) SSHOPTIONS=$2   ; shift 2 ;;
      -n| --node    ) NODE=$2         ; shift 2 ;;
      --) shift; break;;
      *)
        echo "Unexpected option: $1 - this should not happen."
        usage ;;
    esac
done
CLUSTER="$@"

[[ $VALID_ARGUMENTS != "0" ]] &&  usage
[[ -z $CLUSTER ]] &&  usage

[[ $COMMAND = 'yml' ]] || [[ $COMMAND = 'jvm' ]] && [[ -z $NODE ]] && usage
[[ $COMMAND = 'yml' ]] || [[ $COMMAND = 'jvm' ]] && [[ -n $TARGET ]] && usage
[[ $COMMAND = 'yml' ]] || [[ $COMMAND = 'jvm' ]] && [[ -n $FILE ]] && usage
[[ $COMMAND = 'ana' ]] && [[ -n $NODE ]] && usage

case $COMMAND in
  yml        ) sync_yml $CLUSTER $NODE "$INDENTY_FILE" "$SSHOPTIONS" ;;
  jvm        ) sync_jvm $CLUSTER $NODE "$INDENTY_FILE" "$SSHOPTIONS" ;;
  ana        ) sync_ana $CLUSTER $SOURCE "$TARGET" "$INDENTY_FILE" "$SSHOPTIONS" ;;
  -h | --help) usage ;;
  *) usage ;;
esac
