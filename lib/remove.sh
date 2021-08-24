#! /bin/bash

function remove_cluster(){
  cluster=$1; shift
  nodes=($(ls $CLUSTER_DIR/$cluster))
  for node in "${nodes[@]}"; do
      _remove_per_node $cluster $node "$@"
  done
}

function remove_node() {
    _remove_per_node "$@"
}

function _remove_per_node() {
  declare -r cluster=$1
  declare -r node=$2
  declare -r identity_file=$3
  declare -r ssh_options=$4
  declare -a transport_params

  load_files
  parse_params $server_file $yml_file
  Transport "${transport_params[@]}"

  function kill_process() {
    ssh_command "[[ -d $es_path ]] && cd $es_path; cat pid"
    status=$?
    pid=$(cat <&$STDOUT_R)
    [[ $status -eq 0 ]] && [[ -n $pid ]] && ssh_command "kill -9 $pid"
    return 0
  }

  function remove() {
    ssh_command "rm -rf $install_path; sudo rm -rf $logs_path; sudo rm -rf $data_path"
  }

  kill_process && remove && echo "Remove $node success." && return 0 || \
  echo "Remove $node failed. Check node status" && return 1
}


function remove_plugin_from_cluster(){
  cluster=$1; shift
  nodes=($(ls $CLUSTER_DIR/$cluster))
  for node in "${nodes[@]}"; do
      _remove_plugin_per_node $cluster $node "$@"
  done
}

function remove_plugin_from_node() {
    _remove_per_node "$@"
}

function _remove_plugin_per_node() {
  declare -r cluster=$1
  declare -r node=$2
  declare -r source=$3
  declare -r identity_file=$4
  declare -r ssh_options=$5
  declare -a transport_params

  load_files
  parse_params $server_file $yml_file
  check_espath || return 1
  Transport "${transport_params[@]}"

  function remove_plugin() {
    ssh_command "cd $es_path; bin/elasticsearch-plugin remove $source"
  }

  function _store_plugin_lst() {
      ssh_command "cd $es_path/plugins; ls" && \
      cat <&$STDOUT_R > $BASE/$PLUGINPATH
  }

  function _message() {
    declare -r node=$2
    declare -r file=$3
    status=$1
    if [ $status -eq 0 ]; then
      printf "%s\n" "${node}: Remove $file is success."
    else
      printf "%s\n"  "${node}: Remove $file is failed." "check transport logs.(escue logs)"
    fi
  }

  remove_plugin && _store_plugin_lst
  _message $? $node $source
}


