#! /bin/bash

source "./config/globals"
source "./lib/utils.sh"
source "./lib/transport.sh"

function _sync() {
  declare -r source=$1
  declare -r target=$2
  scp_transport $source $target
}

function message() {
    declare -r node=$2
    declare -r file=$3
    status=$1
    if [ $status -eq 0 ]; then
      printf "%s\n" "${node}: $file synchronization  is success."
    else
      printf "%s\n"  "${node}: $file synchronization is failed." "check transport logs.(escue check transport-logs)"
    fi
}

function sync_yml {
  declare -r cluster=$1
  declare -r node=$2
  declare -r identity_file=$3
  declare -a transport_params

  load_files
  parse_params $server_file $yml_file
  check_espath || return 1
  Transport "${transport_params[@]}"

  _sync $yml_file $es_path/config
  message $? $node $YMLFILE


}

function sync_jvm {

  declare -r cluster=$1
  declare -r node=$2
  declare -r identity_file=$3
  declare -a transport_params

  load_files
  parse_params $server_file $yml_file
  check_espath || return 1
  Transport "${transport_params[@]}"

  _sync $jvm_file $es_path/config
  message $? $node $JVMFILE
}

function sync_ana() {
  cluster=$1; shift
  nodes=($(ls $CLUSTER_DIR/$cluster))
  for node in "${nodes[@]}"; do
      _sync_ana_per_node $cluster $node "$@"
  done
}


function sync_ana_per_node() {
    _sync_ana_per_node "$@"
}

function _sync_ana_per_node {
  declare -r cluster=$1
  declare -r node=$2
  declare -r source=$3
  declare -r target=$4
  declare -r identity_file=$5
  declare -r ssh_options=$6
  declare -a transport_params

  load_files
  parse_params $server_file $yml_file
  check_espath || return 1
  Transport "${transport_params[@]}"

  [[ -z $target ]] && sync_target="$es_path/config/analysis"
  [[ -n "$target" ]] && sync_target="$es_path/config/$target"
  ssh_command "[[ ! -d $sync_target ]] && mkdir -p $sync_target"
  _sync $source $sync_target
  message $? $node $source
}
