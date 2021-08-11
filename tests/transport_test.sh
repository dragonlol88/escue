#! /bin/bash

load test_helper.sh
RSANAME="testrsa"

setup()
{
  source ./lib/transport.sh
  rm -rf testing && mkdir testing
  cd testing

  testing_dir=$(pwd)
  cp_file="auth_copy"
  printf "$RSANAME\n" | ssh-keygen -t rsa -N ''
  cat ~/.ssh/authorized_keys > $cp_file
  cat "${testing_dir}/${RSANAME}.pub" &>> ~/.ssh/authorized_keys

  dummy_host=11.11.11.11
  host=localhost
  port=9200
  user=$(whoami)
  identity_file="${testing_dir}/${RSANAME}"
  ssh_options=$5
  Transport "$host" "$user" "$port"  "$identity_file" "$ssh_options"

}

teardown() {
  cat $cp_file > ~/.ssh/authorized_keys
  cd ..
  rm -rf testing
}


@test "Test scp File Transport with identity file" {
  touch testfile
  transport_dir=$(mkdir transport; cd transport || exit 1; pwd)
  echo $testfile
  echo $transport_dir
  scp_transport testfile $transport_dir

  [ -e "${transport_dir}/testfile" ]

}

@test "Test scp File Transport with no identity file" {
  touch testfile
  identity_file=""
  transport_dir=$(mkdir transport; cd transport || exit 1; pwd)
  echo $transport_dir
  scp_transport testfile $transport_dir
  [ -e "${transport_dir}/testfile" ]

}

@test "Test ssh File Transport" {
  test_file=$testing_dir/helloescue
  ssh_command "echo helloescue > $test_file "

  [ -e "$testing_dir/helloescue" ]

  line=$(cat $test_file)
  [ $line = 'helloescue' ]
}



