#! /bin/bash

JoinBy (){
  # join by specified seperator.
  # seperator: ","
  # target: "hello" "world"
  # predict: "hello,world"

  local IFS="$1"
  shift
  echo "$*"
}


CreateFile()
{
  # if file does exist, return 1
  # otherwise, create file and return 0
  # input: file which contain directory
  if [ -e "${1}" ]; then
    return 1
  else
    touch "${1}"
    return 0
  fi
}



MoveTo()
{
  dir=$1

  # if directory does not exits, create directory.
  # if not just move to the directory.
  if [ ! -d "${dir}" ]; then
    mkdir -p $dir
  fi
  echo "$( cd "$dir" || exit 1; pwd)"
}



CheckFor()
{

  # if user has been added already, return 1 ,
  # otherwise return 0
  checkarr="$(JoinBy , "$1")"
  echo ",${checkarr}," | grep ",${2},"
  if [ $? == 0 ]; then
    return 1
  else
    return 0
  fi
}