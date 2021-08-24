#! /bin/bash

unset COMMAND
unset CLUSTER
unset VERSION

PARENT_PATH=$( cd "$(dirname "$0")" && cd .. || exit 1; pwd )
lib_path=$PARENT_PATH/lib
libraries=($(ls $lib_path))
for library in "${libraries[@]}"; do source $lib_path/$library; done
source "${PARENT_PATH}/config/globals"
function usage()
{
  cat "./docs/cluster"
  exit 1
}

COMMAND=$1; shift
PARSED_ARGUMENTS=$(getopt -a -n "escue cluster" -o po:i:s: --long version:,plugin,source:,ptype:, -- "$@")
VALID_ARGUMENTS=$?
eval set -- "$PARSED_ARGUMENTS"
while : ; do
    case $1 in
      -p | --plugin ) IS_PLUGIN=1     ; shift 1 ;;
      --ptype       ) PLUGIN_TYPE=$2  ; shift 2 ;;
      -s|--source   ) SOURCE=$2       ; shift 2 ;;
      -i            ) INDENTY_FILE=$2 ; shift 2 ;;
      -o            ) SSHOPTIONS=$2   ; shift 2 ;;
      --) shift; break ;;
      *)
        echo "Unexpected option: $1 - this should not happen."
        usage ;;
    esac
done

CLUSTER="$@"

[[ $VALID_ARGUMENTS != "0" ]] && usage
[[ -z $CLUSTER ]] && [[ $COMMAND != 'list' ]] && usage
[[ -z $CLUSTER ]] && [[ -n $IS_PLUGIN ]] && usage
[[ $COMMAND != 'install' ]] && [[ $COMMAND != 'remove' ]] && [[ $COMMAND != 'list' ]] && [[ $IS_PLUGIN = 1 ]] && usage
[[ $COMMAND = 'install' ]] && [[ $IS_PLUGIN = 1 ]] && [[ -z $PLUGIN_TYPE ]]  && usage
[[ $COMMAND = 'install' ]] && [[ $IS_PLUGIN = 1 ]] && [[ -z "$SOURCE" ]]  && usage
[[ $COMMAND = 'remove' ]] && [[ $IS_PLUGIN = 1 ]] && [[ -n "$PLUGIN_TYPE" ]] && usage
[[ $COMMAND = 'remove' ]] && [[ $IS_PLUGIN = 1 ]] && [[ -z "$SOURCE" ]] && usage
[[ $COMMAND = 'install' ]] || [[ $COMMAND = 'remove' ]] && [[ -z $IS_PLUGIN ]] && [[ -n "$PLUGIN_TYPE" ]] && usage
[[ -n "$PLUGIN_TYPE" ]] && [[ $PLUGIN_TYPE != "core" ]] && [[ $PLUGIN_TYPE != "file" ]] && [[ $PLUGIN_TYPE != "url" ]] && usage


function delete_cluster() {
  rm -rf $CLUSTER_DIR/$CLUSTER
}

case $COMMAND in
  delete  ) delete_cluster $CLUSTER ;;
  create  ) create_cluster $CLUSTER ;;
  install )
    [[ -z $IS_PLUGIN ]] && \
    install_cluster $CLUSTER $SOURCE "$INDENTY_FILE" "$SSHOPTIONS" || \
    install_plugins $CLUSTER $SOURCE "$INDENTY_FILE" "$SSHOPTIONS" "$PLUGIN_TYPE" ;;
  restart ) restart_cluster $CLUSTER "$INDENTY_FILE" "$SSHOPTIONS";;
  remove  )
    [[ -z $IS_PLUGIN ]] && \
    remove_cluster $CLUSTER "$INDENTY_FILE" "$SSHOPTIONS" || \
    remove_plugin_from_cluster $CLUSTER $SOURCE "$INDENTY_FILE" "$SSHOPTIONS";;
  list    )
    [[ -z $IS_PLUGIN ]] && \
        get_cluster_lst || \
        get_plugin_list $CLUSTER
        ;;
  -h|--help) usage ;;
  *);;
esac
