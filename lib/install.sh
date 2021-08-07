#! /bin/bash

source "./config/globals"
source "./lib/utils.sh"
source "./lib/transport.sh"
source "./lib/formatter.sh"

function parse_params(){

  user=$(get_param $serverUserName "=" $1)
  host=$(get_param $serverHost "=" $1)
  install_path=$(get_param $installPath "=" $1)
  port=$(get_param $HTTPPort ":" $2)
  data_path=$(get_param $dataPath ":" $2)
  logs_path=$(get_param $logsPath ":" $2)

}

function install_cluster() {
  cluster=$1; shift
  nodes=($(ls $CLUSTER_DIR/$cluster))
  InstallFormatter "${nodes[@]}"
  for node in "${nodes[@]}"; do
      first_col $node
      _install $cluster $node "$@"
      printf "\n"
  done
}
function install_node() {
    node=$2
    InstallFormatter $node
    first_col $node
    _install "$@"
    printf "\n"
}

function _install() {
  cluster=$1
  node=$2
  file=$3 # install file location
  identity_file=$4
  ssh_options=$5



  nodeloc="$CLUSTER_DIR/$cluster/$node"
  yml_file="$nodeloc/$YMLFILE"
  jvm_file="$nodeloc/$JVMFILE"
  sever_file=$nodeloc/$SEVERFILE

  STDOUT=$(mktemp)

  parse_params $sever_file $yml_file
  Transport $host $port $user $identity_file  $cluster $node $STDOUT $ssh_options


  function _transmit() {

    ssh_command "mkdir $install_path" && \
    scp_transport $file $install_path && \
    check_sucess $TRANSMIT_HEADER && return 0 || \
    check_fail $TRANSMIT_HEADER && return 1

  }

  function _decompress() {

    ssh_command "cd $install_path ; tar -xvf ${file##*/} | sed -ne '1p'"  && \
    check_sucess $TRANSMIT_HEADER && return 0 || \
    check_fail $TRANSMIT_HEADER && return 1

  }

  function _configure() {
    es_path=$(cat $STDOUT)
    config_path="${install_path}/${es_path}config"
    scp_transport $yml_file "${config_path}/$YMLFILE" && \
    scp_transport $jvm_file "${config_path}/$JVMDIR/$JVMFILE" && \
    ssh_command "sudo [ ! -d  $data_path ] && sudo mkdir -p $data_path ; sudo chown -R $user $data_path" && \
    ssh_command "sudo [ ! -d  $logs_path ] && sudo mkdir -p $logs_path ; sudo chown -R $user $logs_path" && \
    check_sucess $CONFIGURATION_HEADER && return 0 || \
    check_fail $TRANSMIT_HEADER && return 1
  }

  function _install_es() {
    ssh_command "cd ${install_path}/${es_path}; bin/elasticsearch -d -p pid | exit" && \
    check_sucess $INSTALL_HEADER && return 0 || \
    check_fail $INSTALL_HEADER && return 1

  }
  _transmit && _decompress && _configure && _install_es

  rm $STDOUT
  INSTALLSTATUS=$?
  return $INSTALLSTATUS
}

install_plugins() {
  echo "Install plugins"
}
