#! /bin/bash

set -e
script_pwd=$(pwd)
source "${script_pwd}/config/globals"

install_dir=$HOME/.local/bin/escue

if [ -d $install_dir ]; then
  echo "escue is already installed on this machine"
else
  mkdir -p $install_dir && cd $install_dir
  # To manage user configurations(indices, node)
  mkdir $USERS_DIR
  echo "installing escue...."
  mkdir lib
  cp -r $script_pwd/lib/* ./lib
  cp $script_pwd/escue .
  echo "Adding escue to bash command"
  current_profile=''
  if [ ! -e $HOME/.bash_profile ]; then
    touch $HOME/.bash_profile
    current_profile=$(cat $HOME/.profile)
  else
    current_profile=$(sed '/export PATH/d' $HOME/.bash_profile)
  fi

  printf '%s\n' "export PATH=${PATH}:$install_dir" "$current_profile" > $HOME/.bash_profile
  chmod a+rx escue
  echo "Install Complete"
fi
