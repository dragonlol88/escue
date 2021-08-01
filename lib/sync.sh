#! /bin/bash

set -e

#source "../http_api.sh"

sink_files()
{
  case $1 in
  -f|--file)
  shift

    ;;
  *)
    ;;
  esac

  echo "sink files"
}


parse_input_file()
{
  echo "parse input file"
}


