#! /bin/bash

load test_helper.sh

setup()
{
  source ./lib/install.sh
  source ./lib/utils.sh
  source ./config/globals
  rm -rf testing && mkdir testing
  cp ./tests/testnode ./testing
  cd testing

}
teardown() {
  cd ..
  rm -rf testing
}


@test "Install parse_params Test" {

  echo """
        [elasticsearch.yml]
        cluster.name: hyundai-ivm
        node.name: node2
        path.data: /data/es/data
        path.logs: /data/es/logs
        http.host: 172.31.1.65
        http.port: 9200
        discovery.seed_hosts: [172.31.3.134:9300]
        cluster.initial_master_nodes: [node1,node2]
      """ > ymlfile

  echo """
        [syncronize]
        config.path=

        [server]
        server.username=ec2-user
        server.host=10.12.101.102
        install.path=/home/ec2-user/install
       """ > serverfile

  echo """
        [jvm.options.d/jvm.options]
        -Xms396mb
        -Xmx396mb
        """ > jvm


  parse_params serverfile ymlfile
  echo $user
  echo $host
  echo $install_path
  echo $port

  [ ${user} = "ec2-user" ]
  [ ${host} = "10.12.101.102" ]
  [ ${install_path} = "/home/ec2-user/install" ]
  [ ${port} = "9200" ]

}

@test "Install creating elasticsearch.yml Test" {
  nodeloc="testnode"
  node_info=$(extract_lines "\[elasticsearch.yml\]" "^\[.*\]$" -e "^#\|.*:$" $nodeloc "$")

  testlines=(
  "[elasticsearch.yml]"
  "cluster.name: hyundai-ivm"
  "node.name: node2"
  "path.data: /data/es/data"
  "path.logs: /data/es/logs"
  "http.host: 172.31.1.65"
  "http.port: 9200"
  "discovery.seed_hosts: [172.31.3.134:9300]"
  "cluster.initial_master_nodes: [node1,node2]"
  )
  count=0
  while read line; do
    echo ${testlines[$count]}
    echo $line
    [ "$line" = "${testlines[$count]}" ]
    ((count=count+1))
  done< <(echo "$node_info")
}

@test "Install extract elasticsearch.yml Test" {
  nodeloc="testnode"
  # testing 으로 복사하는 과정에서 마지막 space가 없어짐
  # testing 할때는 .*:\s$ -> .*:$
  node_info=$(extract_lines "\[elasticsearch.yml\]" "^\[.*\]$" -e "^#\|.*:$" $nodeloc "$")
  ymlfile=$(echo "$node_info" | sed -ne 's/^\[\(.*\)\]$/\1/ p')
  [ $ymlfile = 'elasticsearch.yml' ]

}


@test "Install set header map Test" {
  INSTALL_HEADERS=("Node Name" "Transmit" "Decompress" "Configuration" "Install")
  declare -A HEADER_MAP
  function _set_header_map() {
    for header in "${INSTALL_HEADERS[@]}"; do
      header_len=${#header}
      HEADER_MAP+=( ["${header}"]="${header_len}" )
    done
  }
  _set_header_map

  [ ${HEADER_MAP["Node Name"]} -eq 9 ]
  [ ${HEADER_MAP["Transmit"]} -eq 8 ]
}

@test "Install set center location Test" {
  INSTALL_HEADERS=("NodeeName" "Transmit" "Decompress" "Configuration" "Install")
  declare -A HEADER_MAP

  function _set_header_map() {
    for header in "${INSTALL_HEADERS[@]}"; do
      header_len=${#header}
      HEADER_MAP+=( ["${header}"]="${header_len}" )
    done
  }
  _set_header_map



  _set_center() {
    first_col_len=${HEADER_MAP["NodeeName"]}
    lens=()
    for elem in "$@"; do
      lens+=(${#elem})
    done
    max_elem_len=$(printf "%d\n" "${lens[@]}" | sort -rn | head -1)

    CENTER_LOC=$([[ $max_elem_len -gt $first_col_len ]] && echo $(((max_elem_len+1)/2)) || echo $(((first_col_len+1)/2)))
  }
  _set_center "set" "cent" "map"
  [ $CENTER_LOC -eq 5 ]

  _set_center "aaa" "aaaaaaaaaaaaaaa" "aaaaaaa"
  echo $CENTER_LOC
  [ $CENTER_LOC -eq 8 ]

}