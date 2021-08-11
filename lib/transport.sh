#! /bin/bash

source "./config/globals"


parse_options() {
  # trim 양쪽 space
  options=$(echo $1 | sed -n -e 's/^\s*// p' | sed -n -e 's/\s*$//p')
  [[ "$options" != ',' ]] && options="-o $(echo $options | sed -n -e 's/,/ -o /g p')" || options=''
}


Transport()
{

  [[ -z $1 ]] && declare -r host=$1 || return 1
  declare -r user=$2
  declare -r port=$3
  declare -r identity_file=$4
  declare ssh_options=$5

  function _construct_ssh_params(){
    options="$ssh_options,"$@""
    parse_options $options
    [[ -n "$identity_file" ]] && \
    ssh_params="$options -i $identity_file "$user@$host" $command" || \
    ssh_params="$options "$user@$host" $command"
    }

  function _construct_scp_params(){
    options="$ssh_options,"$@""
    parse_options $options
    [[ -n "$identity_file" ]] && \
    scp_params="$options -i $identity_file $source "$user@$host":$target" || \
    scp_params="$options $source "$user@$host":$target"
  }
  
  function _set_stdout() {
    STDOUT=$(mktemp)
    exec {STDOUT_W}>$STDOUT
    exec {STDOUT_R}<$STDOUT
    rm $STDOUT
  }

  function _set_stderr() {
    STDERR=$(mktemp)
    exec {STDERR_W}>$STDERR
    exec {STDERR_R}<$STDERR
    rm $STDERR
  }

  function get_stderr() {
    echo $STDERR_R
  }

  function get_stdout(){
    echo $STDOUT_R
  }

  function ssh_command(){

    # options: ssh options
    # key=value or key=value,value

    # multiple options
    # -o key1=value1 -o key2=value2

    command=$1 # requirement parameter
    shift
    _set_stdout
    _set_stderr
    _construct_ssh_params "$@"
    ssh $ssh_params >$STDOUT_W 2>&$STDERR_W
    [[ $? -ne 0  ]] && _log_error "ssh" $STDERR_R && return 1 || return 0
  }

  function scp_transport()
  {
    source=$1
    target=$2
    shift 2
    _set_stdout
    _set_stderr
    _construct_scp_params "$@"
    scp $scp_params >$STDOUT_W 2>&$STDERR_W
    [[ $? -ne 0 ]] && _log_error "scp" $STDERR_R && return 1 || return 0
  }

  function _log_error() {
  # $1 location which raise error from
  # $2 stderr file descriptor temporally
  msg="Message: $1 $(cat <&$2)"
  echo "[ `date` $msg ]" &>> $TRANSPORTERRORLOGPATH
  }

}

