#! /bin/bash


source "./lib/utils.sh"

_create_node()
{
  cur_loc=$1

  nodes="$(ls "$cur_loc")"
  ehco "Current node list: $(JoinBy "," "${nodes[@]}") "
  echo -n "Enter node name(enter q for quit): "
  read node
  if [ ${node} == 'q' ]; then
    exit 0
  fi
  CheckFor "${nodes[@]}" "${node}"

  # status check
  if [ $? != 0 ]; then
    echo "$node has been added already, enter other name"
  else
    CreateNode "${cur_loc}/${node}" "${node}"
  fi
}

_create_cluster()
{
  clusters="$(ls "$cur_loc")"
  printf "%s\n" "Create Cluster" "Cluster name must be same with es configured name."
  echo -n "Enter cluster name: "
  read cluster

  # Check cluster name if exist
  # if exist, exit
  CheckFor "${clusters[@]}" "${cluster}"

  # status check
  if [ $? != 0 ]; then
    echo "$cluster has been added already"
    exit 1
  else
    cur_loc="${cur_loc}/${cluster}"
    MoveTo "${cur_loc}"
  fi

}

CreateCluster()
{
  # register cluster
  # first, make cluster directory
  # second, make nodes

  ClusterDir=$1

  if [ ! -d "${ClusterDir}" ]; then
    mkdir -p ClusterDir
  fi

  cur_loc=$( cd "$ClusterDir" || exit 1; pwd)
  cur_loc="$(_create_cluster ${cur_loc})"

  # create multiple node
  # for quit, enter q
  while :; do
    _create_node "$cur_loc"
  done

}

CreateIndex()
{
  echo "Add index"
}

CreateTestNode()
{
  file=$1
  hostfile=$2
  host=$3

  CreateFile "${file}"
  CreateFile "${hostfile}"
  curl -XGET "http://${host}/_nodes/_all" | jq . > "${file}"
  echo "${host}" > "${hostfile}"
}

CreateNode()
{
  file=$1
  node=$2
  host_file="${file}_host"

  CreateFile "$file"
  CreateFile "$host_file"
  echo -n "Enter ${node}'s host(IP:PORT): "
  read host

  curl -XGET "http://${host}/_nodes/_all" | jq . > "$file"
  echo "$host" > "$host_file"
}