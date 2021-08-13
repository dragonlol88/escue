#! /bin/bash

source "./config/globals"
source "./lib/utils.sh"
source "./lib/transport.sh"
source "./lib/formatter.sh"

function parse_params(){
  user=$(get_param $server_user_name_key "=" $1)
  host=$(get_param $server_host_key "=" $1)
  install_path=$(get_param $install_path_key "=" $1)
  port=$(get_param $http_port_key ":" $2)
  data_path=$(get_param $data_path_key ":" $2)
  logs_path=$(get_param $logs_path_key ":" $2)
}


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

  BASE="$CLUSTER_DIR/$cluster/$node"
  sever_file="$BASE/$SEVERFILE"
  jvm_file="$BASE/$JVMFILE"
  yml_file="$BASE/$YMLFILE"

  parse_params $sever_file $yml_file
  transport_params=($host $user $port $identity_file $ssh_options)
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
    es_path="${install_path}/$(cat <&$STDOUT_R)"
    config_path="${es_path}config"
    scp_transport $yml_file "${config_path}/$YMLFILE" && \
    scp_transport $jvm_file "${config_path}/$JVMDIR/$JVMILE" && \
    ssh_command "sudo [ ! -d  $data_path ] && sudo mkdir -p $data_path ; sudo chown -R $user $data_path" && \
    ssh_command "sudo [ ! -d  $logs_path ] && sudo mkdir -p $logs_path ; sudo chown -R $user $logs_path" && \
    check_sucess $CONFIGURATION_HEADER && return 0 || \
    check_fail $TRANSMIT_HEADER && return 3
  }

  function _install_es() {
    ssh_command "sudo -b su; ulimit -n 65535; ulimit -l unlimited; sudo sysctl -w vm.max_map_count=262144" &&
    ssh_command "cd ${es_path}; bin/elasticsearch -d -p pid | exit" && \
    check_sucess $INSTALL_HEADER && return 0 || \
    check_fail $INSTALL_HEADER && return 4
  }

  function recover() {
    ssh_command "rm -rf $install_path; sudo rm -rf $logs_path; sudo rm -rf $data_path"
  }
  _transmit && _decompress && _configure && _install_es || recover
}
