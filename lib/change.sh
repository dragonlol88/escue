#! /bin/bash

function change_config() {
  declare -r cluster=$1
  declare -r node=$2
  declare -r config=$3
  load_files

  case $config in
    yml ) vi $yml_file;;
    jvm ) vi $jvm_file;;
    server) vi $server_file;
  esac
}