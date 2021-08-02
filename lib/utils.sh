#! /bin/bash

joinBy (){
  # join by specified seperator.
  # seperator: ","
  # target: "hello" "world"
  # predict: "hello,world"

  local IFS="$1"
  shift
  echo "$*"
}


splitStr()
{
  # -i|--idx are options
  # for returning specific index element.

  local IFS="$1"
  str=$2
  shift 2
  arr=("${str[@]}")
  arr=(${arr[*]})

  case $1 in
    --idx|-i)
      echo "${arr[$1]}"
      ;;
    *)
      echo "${arr[@]}"
      ;;
  esac
}


createFile()
{
  # if file does exist, return 1
  # otherwise, create file and return 0
  # input: file which contain directory
  if [ -e "$1" ]; then
    return 1
  else
    touch "$1"
    return 0
  fi
}


moveTo()
{
  dir=$1

  # if directory does not exits, create directory.
  # if not just move to the directory.
  if [ ! -d "${dir}" ]; then
    mkdir -p $dir
  fi
  echo "$( cd "$dir" || exit 1; pwd)"
}



checkFor()
{
  where=$1

  output=$(ls "${where}" 2>&1 | sed -ne 's/.\+\(No such file or directory\)$/\1/ p')
  if [ -z "${output}" ]; then
    return 1
  else
    return 0
  fi
}


extractLines(){

  # -e or --exclude are options

  p1=$1
  p2=$2
  shift 2
  case $1 in
    -e|--exclude)
      shift
      sed -n '/'"$p1"'/, /'"$p2"'/ p' $2 | sed -e '/'"$1"'/ d' | sed -e '/^\s*$/ d'
    ;;
    *)
      sed -n '/'"${p1}"'/, /'"${p2}"'/ p' $1 ;;
  esac

}

requestInput(){
  request=$1

#  echo $n "${request}" : $c
  read -rp "${1}: " name
  echo "$name"
}


