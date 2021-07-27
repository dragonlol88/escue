#! /bin/bash

load test_helper.sh

setup()
{
  source ./lib/utils.sh
  rm -rf testing && mkdir testing
  cd testing

}

teardown() {
  cd ..
  rm -rf testing
}


@test "Utils JoinBy Test" {

  predict="hello,world,shell,script"
  itemarr=("hello" "world" "shell" "script")

  [ $predict == "$(JoinBy , "hello" "world" "shell" "script")" ]
  [ $predict == "$(JoinBy , "${itemarr[@]}" )" ]
}



@test "Utils MoveTo Test" {

  testdir="$(pwd)/esrescue"
  pwd="$(MoveTo "$testdir")"

  [ -d ${testdir} ]
  [ "$pwd" = "$testdir" ]
  rm -rf $testdir

}

@test "Utils CreateFile Test" {
  testfile="$(pwd)/test.txt"

  # first testfile
  # and return 0 return code
  run CreateFile "$testfile"
  [ -e "$testfile" ]
  [ $status == 0 ]

  # next file create return code 1, because file already exist.
  run CreateFile "$testfile"
  [ $status == 1 ]
}



@test "Utils CheckFor Test" {

  # if user has been added already, return 1 ,
  # otherwise return 0

  clusters="sunny,leo,jennie,theo,jerry"
  exist_clusters=("sunny" "leo" "jennie" "theo" "jerry")
  non_exist_clusters=("chris" "bree" "mayo" "lj")

  for cluster in "${exist_clusters[@]}"; do
    run CheckFor $clusters $cluster
    [ $status == 1 ]
  done

  for cluster in "${non_exist_clusters[@]}"; do
    run CheckFor $clusters $cluster
    [ $status == 0 ]
  done

}
