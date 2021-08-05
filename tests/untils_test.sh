#! /bin/bash

load test_helper.sh

setup()
{
  source ./lib/utils.sh
  source ./config/globals
  rm -rf testing && mkdir testing
  cp ./config/question ./testing
  cd testing

}

teardown() {
  cd ..
  rm -rf testing
}

@test "Utils split_str Test" {
  inputitem="hello,world,shell,script"
  predict=("hello" "world" "shell" "script")
  result=($(split_str , $inputitem))
  for ((n; n < ${#predict[*]}; n++)); do
    [ "${predict[n]}" = "${result[n]}" ]
  done

}

@test "Utils split_str Test with index" {
  hosts=$( split_str ":" "localhost:9200" -i "0" )
  echo $hosts
  [ "${hosts}" = "localhost" ]

  hosts=$( split_str ":" "localhost:9200" --idx "1" )
  echo $hosts
  [ $hosts = "9200" ]

}

@test "Utils split_str Test with space" {
  testline=("localhost" "9200 world")
  count=0
  while read line; do
    [ "$line" = "${testline[${count}]}" ]
    ((count=count+1))
  done< <(echo "localhost=9200 world" | sed 's/\(.\+\)=\(.\+\)/\1\n\2/g')

}

@test "Utils join_by Test" {

  predict="hello,world,shell,script"
  itemarr=("hello" "world" "shell" "script")

  [ $predict == "$(join_by , "hello" "world" "shell" "script")" ]
  [ $predict == "$(join_by , "${itemarr[@]}" )" ]
}



@test "Utils move_to Test" {

  testdir="$(pwd)/esrescue"
  pwd="$(move_to "$testdir")"

  [ -d ${testdir} ]
  [ "$pwd" = "$testdir" ]
  rm -rf $testdir

}

@test "Utils create_file Test" {
  testfile="$(pwd)/test.txt"

  # first testfile
  # and return 0 return code
  run create_file "$testfile"
  [ -e "$testfile" ]
  [ $status == 0 ]

  # next file create return code 1, because file already exist.
  run create_file "$testfile"
  [ $status == 1 ]
}



@test "Utils check_for Test" {

  # if user has been added already, return 1 ,
  # otherwise return 0

  root_dir=$(cd .. || exit 1; pwd)
  echo $root_dir
  run check_for "${root_dir}/escue"
  [ $status = 1 ]
  run check_for "${root_dir}/escue2"
  [ $status = 0 ]
}


@test "Utils extract_lines Test" {

  #Todo 바꾸기 dir 바꾸기
  file="/home/ec2-user/escue/config/question"
  testlines=("node.roles=Enter node roles:"
             "path.data=Enter node data path:"
              "path.logs=Enter node logs path:"
              "http.host=Enter node host:"
              "http.port=Enter node http port:"
              "transport.port=Enter node transport port:"
              "discovery.seed_hosts=Enter node seed hosts:"
              "cluster.initial_master_nodes=Enter node initial master nodes:"
              "server.host=Enter server host:"
              "server.username=Enter server user name:"
              "install.path=Enter server install path:"
              "config.path=Enter config path:"
              "jvm.heap=Enter heap size:"
            )
  count=0
  # sed -n '/\[node\]/, /\[.*\]/ p' question | sed -e '/^#\|\[.*\]/ d'
  while read line; do
    if [ -z "${line}" ] ; then
      continue
    fi
    trim=$(echo $line | sed -e 's/\s*$//')

#    echo "${testlines[$count]}"
#    echo $trim
    [ "$trim" = "${testlines[$count]}" ]
    ((count=count+1))
  done< <(extract_lines "\[node\]" "\[.*\]" -e "^#\|\[.*\]\|^\s*$" $file)
}


@test "Utils extract_lines with trim last line Test" {

  #Todo 바꾸기 dir 바꾸기
  file="/home/ec2-user/escue/config/question"
  testlines=("node.roles=Enter node roles:"
             "path.data=Enter node data path:"
              "path.logs=Enter node logs path:"
              "http.host=Enter node host:"
              "http.port=Enter node http port:"
              "transport.port=Enter node transport port:"
              "discovery.seed_hosts=Enter node seed hosts:"
              "cluster.initial_master_nodes=Enter node initial master nodes:"
              "server.host=Enter server host:"
              "server.username=Enter server user name:"
              "install.path=Enter server install path:"
              "config.path=Enter config path:"
            )
  count=0

  # sed -n '/\[node\]/, /\[.*\]/ p' question | sed -e '/^#\|\[.*\]/ d'
  while read line; do
    if [ -z "${line}" ] ; then
      continue
    fi
    trim=$(echo $line | sed -e 's/\s*$//')

    [ "$trim" = "${testlines[$count]}" ]
    ((count=count+1))
  done< <(extract_lines "\[node\]" "\[.*\]" -e "^#\|\[.*\]\|^\s*$" $file "$")
}


@test "Utils get_param Test" {

  echo """
  server.username=ec2-user
  http.port: 9200
  """ > testfile

  username=$(get_param "server.username"  "=" testfile )
  port=$(get_param "http.port"  ":" testfile )
  [ $username = 'ec2-user' ]
  [ $port = '9200' ]

}