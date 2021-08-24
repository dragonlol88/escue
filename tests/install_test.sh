#! /bin/bash

load test_helper.sh

setup()
{
  source ./lib/install.sh
  source ./lib/create.sh
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
        server.username: ec2-user
        server.host: 10.12.101.102
        install.path: /home/ec2-user/install
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

@test "Create formatting file Test" {
  declare -A configs=(["s_http.port"]=1 ["s_network.host"]=2 ["s_discovery.seed_hosts"]=3 \
                          ["v_hello"]=1 ["v_world"]=2 ["v_escue"]=3)
  declare -a pairs
  _format_file s_
  [ "${pairs[1]}" = "http.port: 1" ]
  [ "${pairs[0]}" = "discovery.seed_hosts: [3]" ]
  [ "${pairs[2]}" = "network.host: 2" ]
}

@test "Create yml  file Test" {
  declare -A configs=(["s_hello"]=1 ["s_world"]=2 ["s_escue"]=3 \
                          ["v_hello"]=1 ["v_world"]=2 ["v_escue"]=3)
  predict_result=( "hello: 1" "escue: 3" "world: 2")
  yml_file=yml
  yml_writer
  result=($(cat $yml_file))
  for ((i=1;i<="${#result[@]}";++i)); do
    [ "${predict_result[$i]}" = "${result[$i]}" ]
  done
}

@test "Create server file Test" {
  declare -A configs=(["jvm_hello"]=1 ["sv_world"]=2)
  predict_result=( "hello: 1" "world: 2")
  server_file=server
  server_writer
  result=$(head -n 1 $server_file)
  echo "${result}"
  [ "${result}" = "world: 2" ]
}