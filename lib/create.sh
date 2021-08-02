#! /bin/bash


source "./lib/utils.sh"
source "./config/globals"

questionPath='/home/ec2-user/escue/config/question'
clusterName="cluster.name"
nodeName="node.name"
configPath="config.path"
HTTPHost="http.host"
HTTPPort="http.port"
serverUserName="server.username"


configureCluster()
{
  moveTo "${cur_loc}/${1}"
}

createCluster()
{
  # register cluster
  # first, make cluster directory

  # $1  cluster directory
  # $2  cluster name

  if [ ! -d "${1}" ]; then
    mkdir -p $1
  fi

  cluster=$2
  cur_loc=$( cd "$1" || exit 1; pwd)

  checkFor "${cur_loc}/${cluster}"
  status=$?
  # status check
  if [ $status = 1 ]; then
    echo "$cluster has been added already"
    echo "Check clusters (escue cluster list) "
    exit 1
  fi

  configureCluster $cluster
  return 0

}

configuredNode()
{
  configs+=(["$clusterName"]="$1")
  configs+=(["$nodeName"]="$2")
  while read question; do
    count=0
    while read line; do
        if [ $count -eq 0 ]; then
          key=$line
        else
          q=$line
        fi
        ((count=count+1))
    done< <(echo $question | sed 's/\(.\+\)=\(.\+\)/\1\n\2/g')

    read -u 1 -p "${q} " input

    # replace q to input
    configs+=( ["${key}"]="${input}" )

  # Extract lines from [node] to next [any string]
  # And remove comment and [...] lines
  done< <(extractLines "\[node\]" "\[.*\]" -e "^#\|\[.*\]" "$questionPath" )
  return 0
}


createNode()
{

  declare -A configs
  cluster=$1
  cluster_dir="${CLUSTER_DIR}/${cluster}"
  nodename=$2

  # Check cluster if exist
  checkFor "${cluster_dir}"
  status=$?
  # status check
  if [ $status = 0 ]; then
      echo "${cluster} cluster does not exit, first create cluster"
      echo "Command: escue cluster create ${cluster}"
      exit 1
  fi

  # Check node if exist
  checkFor "${cluster_dir}/${nodename}"
  status=$?
  # status check
  if [ $status = 1 ]; then
      echo "${nodename} has been added already, enter other name"
      exit 1
  fi

  configuredNode $cluster $nodename
  # save status
  # because status code($1) has been change after if clause
  configureNodeStatus=$?

  if [ $configureNodeStatus -eq 0 ]; then
    printf "%s\n" \
          "[elasticsearch.yml]" \
          "${clusterName}=${configs[${clusterName}]}"\
          "${nodeName}=${configs[${nodeName}]}"\
          "${HTTPHost}=${configs[${HTTPHost}]}"\
          "${HTTPPort}=${configs[${HTTPPort}]}"\
          ""\
          "[syncronize]"\
          "${configPath}=${configs[${configPath}]}"\
          ""\
          "[server]"\
          "${serverUserName}=${configs[${serverUserName}]}"\
          > "${cluster_dir}/${nodename}"
    return 0
  fi
}