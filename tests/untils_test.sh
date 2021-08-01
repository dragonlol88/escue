#! /bin/bash

load test_helper.sh

setup()
{
  source ./lib/utils.sh
  source ./config/globals
  rm -rf testing && mkdir testing
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

  clusters="sunny,leo,jennie,theo,jerry"
  exist_clusters=("sunny" "leo" "jennie" "theo" "jerry")
  non_exist_clusters=("chris" "bree" "mayo" "lj")

  for cluster in "${exist_clusters[@]}"; do
    run checkFor $clusters $cluster
    echo $cluster
    [ $status == 1 ]
  done

  for cluster in "${non_exist_clusters[@]}"; do
    run checkFor $clusters $cluster
    [ $status == 0 ]
  done

}


@test "Utils extractLines Test" {

  #Todo 바꾸기 dir 바꾸기
  file="/home/ec2-user/escue/config/question"
  testlines=("node.name=Enter node name(enter q for quit):"
            "config.path=Enter <>'s config path:"
            "http.host=Enter <>'s host:"
            "http.port=Enter <>'s port:"
            "server.username=Enter <>'s user name:")
  count=0

  # sed -n '/\[node\]/, /\[.*\]/ p' question | sed -e '/^#\|\[.*\]/ d'
  while read line; do
    if [ -z "${line}" ] ; then
      continue
    fi
    echo $line
    trim=$(echo $line | sed -e 's/\s*$//')

    echo "${testlines[$count]}"
    [ "$trim" = "${testlines[$count]}" ]
    ((count=count+1))
  done< <(extractLines "\[node\]" "\[.*\]" -e "^#\|\[.*\]\|^\s*$" $file)
}


