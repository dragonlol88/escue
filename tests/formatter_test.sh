#! /bin/bash

load test_helper.sh

setup()
{
  source ./lib/formatter.sh
  rm -rf testing && mkdir testing
  cd testing


}

teardown() {
  cd ..
  rm -rf testing
}


@test "Test Formatter get_center" {

  InstallFormatter sunny1 sunny2 sunny1
  center=$(get_center)
  [ $center -eq 5 ]

  InstallFormatter sunny1sunny2sunny1 sunny23 sunny423
  center=$(get_center)
  [ $center -eq 9 ]
}

@test "Test Formatter get_max_len" {

  InstallFormatter sunny1 sunny2 sunny1
  max_len=$(get_max_len)
  echo $max_len
  [ $max_len -eq 6 ]

  InstallFormatter sunny1sunny2sunny1 sunny23 sunny423
  max_len=$(get_max_len)
  echo $max_len
  [ $max_len -eq 18 ]
}

