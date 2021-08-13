#! /bin/bash


source "./lib/utils.sh"
source "./config/globals"

function create_cluster()
{
  # register cluster
  # first, make cluster directory

  # $1  cluster directory
  # $2  cluster name

  [[ ! -d "${1}" ]] && mkdir -p $1

  cluster=$2
  cur_loc=$( cd "$1" || exit 1; pwd)

  check_for "${cur_loc}/${cluster}"

  # status check
  STATUS=$?
  msg="$cluster has been added already\nCheck clusters (escue cluster list) "
  [[ $STATUS -ne 0 ]] && echo -e $msg && return 1
  move_to "${cur_loc}/$cluster" && return 0 || return 1

}

function configure_node()
{

  configs+=(["yml_$cluster_name"]="$1")
  configs+=(["yml_$node_name"]="$2")
  while read question; do
    count=0
    while read line; do
      [[ $count -eq 0 ]] && key=$line || q=$line
      ((count++))
    done< <(echo $question | sed 's/\(.\+\)=\(.\+\)/\1\n\2/g')

    read -u 1 -p "${q} " input
    # replace q to input

    configs+=(["${key}"]="${input}")

  # Extract lines from [node] to next [any string]
  # And remove comment and [...] lines
  done< <(extract_lines "\[node\]" "\[.*\]" -e "^#\|\[.*\]\|^[[:space:]]*$" "$QUSTION_PATH" )

  return 0
}


function create_node()
{

  declare -A configs
  cluster=$1
  nodename=$2
  cluster_dir="$CLUSTER_DIR/$cluster"

  # Check cluster if exist
  check_for "${cluster_dir}"
  status=$?
  # status check
  [[ $status = 0 ]] && echo "${cluster} cluster does not exit, first create cluster\n" && exit 1

  # Check node if exist
  check_for "${cluster_dir}/${nodename}"
  status=$?
  # status check
  [[ $status = 1 ]] && echo "${nodename} has been added already, enter other name" && exit 1

  configure_node $cluster $nodename

  # save status
  # because status code($1) has been change after if clause
  configureNodeStatus=$?
  if [ $configureNodeStatus -eq 0 ]; then
    base="${cluster_dir}/${nodename}"
    mkdir -p $base
    yml_file="$base/$YMLFILE"
    jvm_file="$base/$JVMFILE"
    server_file="$base/$SEVERFILE"

    yml_writer && jvm_writer && server_writer
    return 0
  fi
}


function _format_file() {
  prefix=$1
  for key in "${!configs[@]}"; do

    if [[ -n $(echo $key | grep $prefix.\\+$) ]]; then
      nky=${key/$prefix/}
      [[ $nky = $node_roles_key ]] || \
      [[ $nky = $seed_hosts_key ]] || \
      [[ $nky = $initial_master_nodes_key ]]  && \
      pairs+=("${nky}: [${configs[${key}]}]") && continue
      pairs+=("${nky}: ${configs[${key}]}")
    fi
  done
}

function yml_writer() {
  declare -a pairs
  _format_file yml_
  printf "%s\n" "${pairs[@]}" | sed -e '/^[[:space:]]*$\|.*:\s*$/ d' > $yml_file

}

function jvm_writer() {
  declare -a pairs
  _format_file jvm_
  printf "%s\n" "${pairs[@]}" | sed -e '/^[[:space:]]*$/ d' > $jvm_file
}

function server_writer() {
  declare -a pairs
  _format_file sv_
  printf "%s\n" "${pairs[@]}" | sed -e '/^[[:space:]]*$\|.*:\s*$/ d' > $server_file

}