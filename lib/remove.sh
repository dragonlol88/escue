source "./config/globals"
source "./lib/utils.sh"
source "./lib/transport.sh"


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
  parse_params $sever_file $yml_file
  Transport "${transport_params[@]}"

  function kill_process() {
    ssh_command "[[ -d $es_path ]] && cd $es_path; cat pid"
    pid=$(cat <&$STDOUT_R)
    ssh_command "kill -9 $pid"
  }

  function remove() {
    ssh_command "rm -rf $install_path; sudo rm -rf $logs_path; sudo rm -rf $data_path"
  }

  kill_process && remove && echo "Remove $node success." && return 0 || \
  echo "Remove $node failed. Check node status" && return 1
}