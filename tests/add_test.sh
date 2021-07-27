#! /bin/bash

load test_helper.sh

setup()
{
  source ./lib/add.sh
  rm -rf testing && mkdir testing
  cd testing

}

teardown() {
  cd ..
  rm -rf testing
}


@test "Create CreateTestNode Test" {
  testfile="$(pwd)/testnode"
  testhostfile="$(pwd)/testnode_host"
  testhost="localhost:9200"


  run CreateTestNode "${testfile}" "$testhostfile" "$testhost"
  [ $status == 0 ]
  linecount=1
  testline=$(cat ${testfile} | while read line; do
                                if [ $linecount -eq 5 ]; then
                                  echo "$line"
                                fi
                                let "linecount++"
                                done
  )
  [ "$testline" = '"failed": 0' ]

  testline=$(head -1 ${testhostfile})
  echo $testline
  [ "$testline" = "$testhost" ]

  rm -rf "$testfile"
  rm -rf "$testhostfile"
}