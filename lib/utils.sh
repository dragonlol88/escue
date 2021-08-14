#! /bin/bash

function join_by(){
  # join by specified seperator.
  # seperator: ","
  # target: "hello" "world"
  # predict: "hello,world"

  local IFS="$1"
  shift
  echo "$*"
}


function split_str()
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

function create_file() {

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


function move_to()
{
  dir=$1

  # if directory does not exits, create directory.
  # if not just move to the directory.
  if [ ! -d "${dir}" ]; then
    mkdir -p $dir
  fi
  echo "$( cd "$dir" || exit 1; pwd)"
}



function check_for()
{
  where=$1

  output=$(ls "${where}" 2>&1 | sed -ne 's/.\+\(No such file or directory\)$/\1/ p')
  if [ -z "${output}" ]; then
    return 1
  else
    return 0
  fi
}


extract_lines(){

  # -e or --exclude are options

  p1=$1
  p2=$2

  shift 2
  case $1 in
    -e|--exclude)
      shift
      if [ ! -z $3 ]; then
        sed -n '/'"$p1"'/, /'"$p2"'/ p' $2 | sed -e '/'"$1"'/ d' | sed -e ''"$3"' d'
      else
        sed -n '/'"$p1"'/, /'"$p2"'/ p' $2 | sed -e '/'"$1"'/ d'
      fi
    ;;
    *)
      if [ ! -z $2 ]; then
        sed -n '/'"${p1}"'/, /'"${p2}"'/ p' $1 | sed -e ''"$3"' d'
      else
        sed -n '/'"${p1}"'/, /'"${p2}"'/ p' $1
      fi
      ;;
  esac

}

function request_input(){
  request=$1

#  echo $n "${request}" : $c
  read -rp "${1}: " name
  echo "$name"
}


function get_param ()
{
  echo $(sed -n '/'"$1"'/ p' $3 | cut -d${2} -f 2 )
}


function parse_params(){
  user=$(get_param $server_user_name_key "=" $1)
  host=$(get_param $server_host_key "=" $1)
  install_path=$(get_param $install_path_key "=" $1)
  port=$(get_param $http_port_key ":" $2)
  data_path=$(get_param $data_path_key ":" $2)
  logs_path=$(get_param $logs_path_key ":" $2)

  transport_params=($host $user $port $identity_file $ssh_options)
  if [ -f "$BASE/$ESPATH" ]; then
    es_path=$(cat "$BASE/$ESPATH")
  fi
}

function load_files() {
  BASE="$CLUSTER_DIR/$cluster/$node"
  sever_file="$BASE/$SEVERFILE"
  jvm_file="$BASE/$JVMFILE"
  yml_file="$BASE/$YMLFILE"
}
