#! /bin/bash

source "./config/globals"

function get_cluster_lst() {

  cluster_lst=($(ls $CLUSTER_DIR))
  printf "%s\n" "Cluster" "${cluster_lst[@]}"
}

function get_node_lst() {

    cluster=$1
    [[ -z $cluster ]] && _all_node_list || _node_list_from_cluster $cluster

}

function _all_node_list() {

    tempfile=$(mktemp) && echo "Cluster,Node" > $tempfile

    nodes=(); files=()
    while read cluster; do
      files+=($(mktemp))
      nodes=($(ls $CLUSTER_DIR/$cluster))
      printf "%s\n" $cluster "${nodes[@]}" > "${files[-1]}"
    done< <(ls $CLUSTER_DIR)
    paste -d , "${files[@]}" > $tempfile
    column -t -s , $tempfile

    rm $tempfile
    while read file; do rm $file ; done< <(echo "${files[@]}")
}

function _node_list_from_cluster() {
    nodes=($(ls $CLUSTER_DIR/$cluster))
    printf "%s\n" $cluster "${nodes[@]}"

}

function get_plugin_list() {
  cluster=$1
  tempfile=$(mktemp)
  basedir=$CLUSTER_DIR/$cluster

  nodes=($(ls $basedir))
  files=()

  for node in "${nodes[@]}"; do
    files+=($(mktemp))
    cat $basedir/$node/$plug/$PLUGINPATH | sed '1 i '"${node}"'' > "${files[-1]}"
  done

  paste -d , "${files[@]}" > $tempfile
  column -t -s , $tempfile
  rm $tempfile
  for file in "${files[@]}"; do rm $file; done

}
