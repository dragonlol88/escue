#! /bin/bash

source "./config/globals"


parse_options() {
  # trim 양쪽 space
  options=$(echo $1 | sed -n -e 's/^\s*// p' | sed -n -e 's/\s*$//p')
  [[ "$options" != ',' ]] && options="-o $(echo $options | sed -n -e 's/,/ -o /g p')" || options=''
}



Transport()
{
  host=$1
  port=$2
  user=$3
  identity_file=$4
  cluster=$5
  node=$6
  STDOUT=$7
  ssh_options=$8


  function construct_ssh_params(){
    [[ -n "$identity_file" ]] && \
    ssh_params="$options -i $identity_file "$user@$host" $command" || \
    ssh_params="$options "$user@$host" $command"
    }

  function construct_scp_params(){
    [[ -n "$identity_file" ]] && \
    scp_params="$options -i $identity_file $source "$user@$host":$target" || \
    scp_params="$options $source "$user@$host":$target"
  }

  function ssh_command(){

    # options: ssh options
    # key=value or key=value,value

    # multiple options
    # -o key1=value1 -o key2=value2

    command=$1 # requirement parameter
    shift
    options="$ssh_options,"$@""

    STDERR=$(mktemp)
    exec {STDERR_W}>$STDERR
    exec {STDERR_R}<$STDERR
    rm $STDERR
    parse_options $options
    construct_ssh_params
    ssh $ssh_params >$STDOUT 2>&$STDERR_W
    [[ $? -ne 0  ]] && error_logs "ssh" $STDERR_R && return 1 || return 0
  }

  function scp_transport()
  {
    source=$1
    target=$2

    shift 2
    options="$ssh_options,"$@""

    STDERR=$(mktemp)
    exec {STDERR_W}>$STDERR
    exec {STDERR_R}<$STDERR
    rm $STDERR

    parse_options $options
    construct_scp_params
    scp $scp_params >$STDOUT 2>&$STDERR_W
    [[ $? -ne 0 ]] && error_logs "scp" $STDERR_R && return 1 || return 0
  }

  function error_logs() {
  # $1 location which raise error from
  # $2 stderr file descriptor temporally
  msg="Message: $1 $(cat <&$2)"
  echo "[ `date` $msg ]" &>> $TRANSPORTERRORLOGPATH
  }

}

