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

@test "Utils splitStr Test" {
  inputitem="hello,world,shell,script"
  predict=("hello" "world" "shell" "script")
  result=($(splitStr , $inputitem))
  for ((n; n < ${#predict[*]}; n++)); do
    [ "${predict[n]}" = "${result[n]}" ]
  done

}

@test "Utils splitStr Test with index" {
  hosts=$( splitStr ":" "localhost:9200" -i "0" )
  echo $hosts
  [ "${hosts}" = "localhost" ]

  hosts=$( splitStr ":" "localhost:9200" --idx "1" )
  echo $hosts
  [ $hosts = "9200" ]

}

@test "Utils splitStr Test with space" {
  testline=("localhost" "9200 world")
  count=0
  while read line; do
    [ "$line" = "${testline[${count}]}" ]
    ((count=count+1))
  done< <(echo "localhost=9200 world" | sed 's/\(.\+\)=\(.\+\)/\1\n\2/g')

}

@test "Utils JoinBy Test" {

  predict="hello,world,shell,script"
  itemarr=("hello" "world" "shell" "script")

  [ $predict == "$(joinBy , "hello" "world" "shell" "script")" ]
  [ $predict == "$(joinBy , "${itemarr[@]}" )" ]
}



@test "Utils MoveTo Test" {

  testdir="$(pwd)/esrescue"
  pwd="$(moveTo "$testdir")"

  [ -d ${testdir} ]
  [ "$pwd" = "$testdir" ]
  rm -rf $testdir

}

@test "Utils CreateFile Test" {
  testfile="$(pwd)/test.txt"

  # first testfile
  # and return 0 return code
  run createFile "$testfile"
  [ -e "$testfile" ]
  [ $status == 0 ]

  # next file create return code 1, because file already exist.
  run createFile "$testfile"
  [ $status == 1 ]
}



@test "Utils CheckFor Test" {

  # if user has been added already, return 1 ,
  # otherwise return 0

  root_dir=$(cd .. || exit 1; pwd)
  echo $root_dir
  run checkFor "${root_dir}/escue"
  [ $status = 1 ]
  run checkFor "${root_dir}/escue2"
  [ $status = 0 ]
}


@test "Utils extractLines Test" {

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
  done< <(extractLines "\[node\]" "\[.*\]" -e "^#\|\[.*\]\|^\s*$" $file)
}


@test "Utils extractLines with trim last line Test" {

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
  done< <(extractLines "\[node\]" "\[.*\]" -e "^#\|\[.*\]\|^\s*$" $file "$")
}


@test "Utils getParam Test" {

  echo """
  server.username=ec2-user
  http.port: 9200
  """ > testfile

  username=$(getParam "server.username"  "=" testfile )
  port=$(getParam "http.port"  ":" testfile )
  [ $username = 'ec2-user' ]
  [ $port = '9200' ]

}