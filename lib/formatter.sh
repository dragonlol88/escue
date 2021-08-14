#! /bin/bash

NODENAME_HEADER="Node Name"
TRANSMIT_HEADER="Transmit"
DECOMPRESS_HEADER="Decompress"
CONFIGURATION_HEADER="Configuration"
INSTALL_HEADER="Install"
INSTALL_HEADERS=("Node Name" "Transmit" "Decompress" "Configuration" "Install")



InstallFormatter(){

  declare -a NODES="$@"
  CENTER_LOC=''
  MAX_LEN=''
  INDENT=4
  count=0

  function get_center() {
      echo $CENTER_LOC
  }

  function get_max_len() {
      echo $MAX_LEN
  }


  function _set_center()
  {
    FIRST_COL_LEN=${#NODENAME_HEADER}
    lens=()
    for elem in "$@"; do
      lens+=(${#elem})
    done
    MAX_LEN=$(printf "%d\n" "${lens[@]}" | sort -rn | head -1)
    CENTER_LOC=$([[ $MAX_LEN -gt $FIRST_COL_LEN ]] && echo $(((MAX_LEN+1)/2)) || echo $(((FIRST_COL_LEN+1)/2)))

  }

  function first_col(){
    col=$1
    col_len=${#col}
    printf "%$((CENTER_LOC-(col_len)/2))s"
    printf "%-$(((col_len1+1)/2 + (MAX_LEN+1)/2 + INDENT))s" "$col"
  }

  function check_fail() {
    col_len=${#1}
    printf "%+$(((col_len+1)/2))s" x

  }

  function check_sucess() {
    col_len=${#1}
    printf "%+$(((col_len+1)/2))s" v
    printf "%+$(((col_len+1)/2 + INDENT))s"

  }

  _set_center $NODES

  for header in "${INSTALL_HEADERS[@]}"; do
    header_len=${#header}
    if [ $count -eq 0 ]; then
      printf "%$((CENTER_LOC-header_len/2))s"
      printf "%-$((header_len/2 + MAX_LEN/2 + INDENT))s" "$header"
    else
      printf "%-$((header_len+INDENT))s" $header
    fi
    ((count=count+1))

  done
  printf "\n"
}

