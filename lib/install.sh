#! /bin/bash

source "./config/globals"
source "./lib/utils.sh"
source "./lib/transport.sh"


parse_params(){

  user=$(getParam $serverUserName "=" $1)
  host=$(getParam $serverHost "=" $1)
  install_path=$(getParam $installPath "=" $1)
  port=$(getParam $HTTPPort ":" $2)
  data_path=$(getParam $dataPath ":" $2)
  logs_path=$(getParam $logsPath ":" $2)

}


installNode() {

  cluster=$1
  node=$2
  file=$3 # install file location
  identity_file=$4
  ssh_options=$5

  # ==============  FLOW   ======================
  # call node information( username, host, install directory)
  nodeloc="$CLUSTER_DIR/$cluster/$node"
  yml_file="$nodeloc/$YMLFILE"
  jvm_file="$nodeloc/$JVMFILE"
  sever_file=$nodeloc/$SEVERFILE

  parse_params $sever_file $yml_file

  # -------------- scp part ---------------------
#            # transfer install tar file
#  echo $host
#  echo $port
#  echo $identity_file
#  echo $ssh_options
#  echo $cluster
#  echo $node
  Transport "$host" "$port" "$user" "$identity_file" "$ssh_options" "$cluster" "$node"


  printf "%s\n" "Creating install directory....."
  ssh_command "mkdir ${install_path}"

  printf "%s\n" "Transmitting install files....."
  scp_transport $file $install_path


  # -------------- ssh command part -------------
  # decompress tar file
  printf "%s\n" "Decompress install files....."
  compress_file=${file##*/}
  es_path=$(ssh_command "cd $install_path ; tar -xvf $compress_file | sed -ne '1p'")

  config_path="${install_path}/${es_path}config"
  printf "%s\n" "Creating elasticsearch.yml....."
  scp_transport $yml_file "${config_path}/$YMLFILE"

  printf "%s\n" "Creating jvm.options....."
  scp_transport $jvm_file "${config_path}/$JVMDIR/$JVMFILE"

  printf "%s\n" "Create elasticsearch data path....."
  ssh_command "sudo [ ! -d  $data_path ] && sudo mkdir -p $data_path ; sudo chown -R $user $data_path"

  printf "%s\n" "Create elasticsearch logs path....."
  ssh_command "sudo [ ! -d  $logs_path ] && sudo mkdir -p $logs_path ; sudo chown -R $user $logs_path"

  printf "%s\n" "Install elasticsearch....."
  ssh_command "cd ${install_path}/${es_path}; bin/elasticsearch -d -p pid | exit" "ConnectTimeout=60"

  printf "$s\n" "Checking cluster connection....."
  printf "%s\n" "Complete install"
  return 0
}


installPlugins() {
  echo "Install plugins"
}
