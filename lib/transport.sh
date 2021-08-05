#! /bin/bash

source "./config/globals"


parse_options() {
  # trim 양쪽 space
  options=$(echo $1 | sed -n -e 's/^\s*// p' | sed -n -e 's/\s*$//p')
  if [ "$options" != ',' ]; then
    options="-o $(echo $options | sed -n -e 's/,/ -o /g p')"
  else
    options=''
  fi
}

Transport()
{

  host=$1
  port=$2
  user=$3
  identity_file=$4
  ssh_options=$5
  cluster=$6
  node=$7

  http_trasport()
  {
    # $1=method
    # $2=url
    # $3=params
    # $4=data
    # $5=headers
    # Options(timeout)

    case $1 in
      -t) echo "Transport HTTP request using curl" > http_request ;;
       *)

         echo "Wait for develop"
      ;;
    esac
  }

  ssh_command(){

    # options: ssh options
    # key=value or key=value,value

    # multiple options
    # -o key1=value1 -o key2=value2

    local stderr
    if [ ! -d logs ]; then
        mkdir logs
    fi
    stderr="./logs/$(uuidgen)"
    command=$1 # requirement parameter
    shift
    options="$ssh_options,"$@""
    parse_options $options
    if [ -n "$identity_file" ]; then
      OUTPUT=$(ssh $options -i $identity_file "$user@$host" $command 2>${stderr})
    else
      OUTPUT=$(ssh $options "$user@$host" $command 2>${stderr})
    fi
    status=$?
    if [ $status -ne 0  ]; then
      ERROR=$(sed -n '1, $ p' ${stderr})
      rm -rf ${stderr}
      echo "ssh $command is failed  $options"
      echo "Check the transport error log(escue logs transporterror)"
      echo "[ `date` ssh_command cluster: $cluster node: $node message: $ERROR]" &>> $TRANSPORTERRORLOGPATH
      exit 1
    fi
    echo "$OUTPUT"
    return 0
  }

  scp_transport()
  {
    local stderr
    if [ ! -d logs ]; then
        mkdir logs
    fi
    stderr="./logs/$(uuidgen)"
    case $1 in
      -t) echo "Transport file using scp protocol" > scp_file_transfer ;;
       *)
         source=$1
         target=$2
         # source
         # target directory
         shift 2
         options="$ssh_options,"$@""
         parse_options $options
         if [ -n "$identity_file" ]; then
           OUTPUT=$(scp $options -i  $identity_file $source "$user@$host:$target" 2>${stderr})
         else
           OUTPUT=$(scp $options $source "$user@$host:$target" 2>${stderr})
         fi

         status=$?
         if [ $status -ne 0 ]; then
            ERROR=$(sed -n '1, $ p' ${stderr})
            rm -rf ${stderr}
            echo "Transfer $source to ${host}'s $target is failed. $options "
            echo "Check the transport error log(escue logs transporterror)"
            echo "[ `date` scp_file_transfer cluster: $cluster node: $node message: $ERROR]" &>> $TRANSPORTERRORLOGPATH
         fi
         echo "$OUTPUT"
         return 0
      ;;
    esac

  }
}

