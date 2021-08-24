#! /bin/bash

function install_cluster() {
  cluster=$1; shift
  nodes=($(ls $CLUSTER_DIR/$cluster))
  InstallFormatter "${nodes[@]}"
  for node in "${nodes[@]}"; do
      first_col $node
      _install_per_node $cluster $node "$@"
      printf "\n"
  done
}

function install_node() {
    node=$2
    InstallFormatter $node
    first_col $node
    _install_per_node "$@"
    printf "\n"
}


function _install_per_node() {
  declare -r cluster=$1
  declare -r node=$2
  declare -r source=$3
  declare -r identity_file=$4
  declare -r ssh_options=$5
  declare -a transport_params

  load_files
  parse_params $server_file $yml_file
  Transport "${transport_params[@]}"

  function _transmit() {
    ssh_command "mkdir $install_path" && \
    scp_transport $source $install_path && \
    check_sucess $TRANSMIT_HEADER && return 0 || \
    check_fail $TRANSMIT_HEADER && return 1
  }

  function _decompress() {
    ssh_command "cd $install_path ; tar -xvf ${source##*/} | sed -ne '1p'"  && \
    check_sucess $TRANSMIT_HEADER && return 0 || \
    check_fail $TRANSMIT_HEADER && return 2
  }

  function _configure() {
    es_dir=$(cat <&$STDOUT_R | sed -n -e 's/\/// p')
    es_path="$install_path/$es_dir"
    echo $es_path > "$BASE/$ESPATH"
    config_path="${es_path}/config"
    plugin_path="${es_path}/$PLUGINPATH"
    analysis_path="$config_path/analysis"

    ssh_command "mkdir -p $plugin_path" && \
    ssh_command "mkdir -p $analysis_path" && \
    ssh_command "sudo -b su; ulimit -n 65535; ulimit -l unlimited; sudo sysctl -w vm.max_map_count=262144" && \
    scp_transport $yml_file "${config_path}/$YMLFILE" && \
    scp_transport $jvm_file "${config_path}/$JVMDIR/$JVMILE" && \
    ssh_command "sudo [ ! -d  $data_path ] && sudo mkdir -p $data_path ; sudo chown -R $user $data_path" && \
    ssh_command "sudo [ ! -d  $logs_path ] && sudo mkdir -p $logs_path ; sudo chown -R $user $logs_path" && \
    check_sucess $CONFIGURATION_HEADER && return 0 || \
    check_fail $TRANSMIT_HEADER && return 3
  }

  function _install_es() {

    ssh_command "cd ${es_path}; bin/elasticsearch -d -p pid | exit" && \
    check_sucess $INSTALL_HEADER && return 0 || \
    check_fail $INSTALL_HEADER && return 4
  }

  function recover() {
    ssh_command "rm -rf $install_path; sudo rm -rf $logs_path; sudo rm -rf $data_path"
  }
  _transmit && _decompress && _configure && _install_es || recover
}


function restart_cluster() {
  cluster=$1; shift
  nodes=($(ls $CLUSTER_DIR/$cluster))
  for node in "${nodes[@]}"; do
      _restart_per_node $cluster $node "$@"
  done
}

function restart_node() {
    _restart_per_node "$@"
}

function _restart_per_node() {


  declare -r cluster=$1
  declare -r node=$2
  declare -r identity_file=$3
  declare -r ssh_options=$4

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

  function restart() {
    ssh_command "sudo -b su; ulimit -n 65535; ulimit -l unlimited; sudo sysctl -w vm.max_map_count=262144" && \
    ssh_command "cd ${es_path}; bin/elasticsearch -d -p pid | exit"
  }

  kill_process && restart && echo "${node}: Restart success." && return 0 || \
  echo "${node}: Restart failed. Check node status" && return 1

}


function install_plugins() {
  cluster=$1; shift
  nodes=($(ls $CLUSTER_DIR/$cluster))
  for node in "${nodes[@]}"; do
      _install_plugin_per_node $cluster $node "$@"
  done
}

function fill_plugin_list_to_file() {
  declare -a plugin_lst=$1
  local IFS=$'\n'
  echo "${plugin_lst[*]}" > $BASE/$PLUGINPATH
}

function _install_plugin_per_node() {
  declare -r cluster=$1
  declare -r node=$2
  declare -r source=$3
  declare -r identity_file=$4
  declare -r ssh_options=$5
  declare -r plugin_type=$6
  declare plugin_path
  declare file_name
  declare -a transport_params

  load_files
  parse_params $server_file $yml_file
  check_espath || return 1
  Transport "${transport_params[@]}"
  file_name=${source##*/}
  plugin_path="$es_path/$PLUGINPATH"

  function _check_plugin() {
    ssh_command "cd $es_path/plugins; ls" &&\
    if_exist=$(cat <&$STDOUT_R | grep $file_name)
    if [ -n "$if_exist" ]; then
       ssh_command "cd $es_path; bin/elasticsearch-plugin remove $source"
    fi

  }

  function _store_plugin_lst() {
      ssh_command "cd $es_path/plugins; ls" && \
      cat <&$STDOUT_R > $BASE/$PLUGINPATH
  }

  function _install_plugin_from_file() {
    ssh_command "[[ ! -d $plugin_path ]] && mkdir -p $plugin_path"
    scp_transport $source $plugin_path && \
    ssh_command "cd $es_path; bin/elasticsearch-plugin install file://$plugin_path/$file_name"
  }

  function _install_core_and_url_plugin() {
    ssh_command "cd $es_path; bin/elasticsearch-plugin install $source"
  }

  function _message() {
    declare -r node=$2
    declare -r file=$3
    status=$1
    if [ $status -eq 0 ]; then
      printf "%s\n" "${node}: Install $file is success."
    else
      printf "%s\n"  "${node}: Install $file is failed." "check transport logs.(escue logs)"
    fi
  }
  _check_plugin
  if [ $plugin_type = 'file' ]; then
      _install_plugin_from_file && _store_plugin_lst
      _message $? $node $file_name
  elif [ $plugin_type = 'core' ] || [ $plugin_type = 'url' ]; then
    _install_core_and_url_plugin && _store_plugin_lst
    _message $? $node $file_name
  else
    echo "escue plugin install does not support $plugin_type type."
  fi
}