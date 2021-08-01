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

  cluster=$(requestInput "Enter cluster name: ")

  # Check cluster name if exist
  # if exist, exit
  output=$(ls "${1}/${cluster}" 2>&1 | sed -ne 's/.\+\(No such file or directory\)$/\1/ p')

  # status check
  if [ -z "${output}" ]; then
    echo "$cluster has been added already"
    return 1
  else
    cur_cluster="$(moveTo "${cur_loc}/${cluster}")"
  fi
}

createCluster()
{
  # register cluster
  # first, make cluster directory
  # second, make nodes

  # $1  cluster directory
  cur_cluster=''
  if [ ! -d "${1}" ]; then
    mkdir -p $1
  fi

  cur_loc=$( cd "$1" || exit 1; pwd)
  while true; do
    configureCluster ${cur_loc}

    if [ $? -eq 1 ]; then
      continue
    else
      break
    fi
  done

  # create multiple node
  # for quit, enter q
  while true; do
    echo $cur_cluster
    createNode "$cur_cluster"
    if [ $? -eq 0 ]; then
      continue
    else
      break
    fi
  done

}


configuredNode()
{

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
    if [ $nodeName = $key ]; then
      if [ "${input}" = 'q' ]; then
        return 1
      fi

      # Check if node exist
      # Todo stderr 보내기
      output=$(ls "${1}/${input}" 2>&1 | sed -ne 's/.\+\(No such file or directory\)$/\1/ p')

      # status check
      if [ -z "${output}" ]; then
        echo "${input} has been added already, enter other name"
        return 2
      fi
    fi

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
  case $1 in
    -t)
      shift
      testCaseNode "$@"
      ;;
    *)
      configuredNode $1
    ;;
  esac
  # save status
  # because status code($1) has been change after if clause
  configureNodeStatus=$?

  if [ $configureNodeStatus -eq 0 ]; then
    printf "%s\n" \
          "[elasticsearch.yml]" \
          "${nodeName}=${configs[${nodeName}]}"\
          "${HTTPHost}=${configs[${HTTPHost}]}"\
          "${HTTPPort}=${configs[${HTTPPort}]}"\
          ""\
          "[syncronize]"\
          "${configPath}=${configs[${configPath}]}"\
          ""\
          "[server]"\
          "${serverUserName}=${configs[${serverUserName}]}"\
          > "/${1}/${configs[${nodeName}]}"
    return 0
  elif [ $configureNodeStatus -eq 2 ]; then
    return 0
  else
    return 1
  fi
}