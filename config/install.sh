#! /bin/bash

set -e

script_dir=$(pwd)
config_dir=$(cd $(dirname "$0") || exit 1; pwd)
source "${config_dir}/globals"


if [ -d $INSTALL_DIR ]; then
  rm -rf $INSTALL_DIR
fi

mkdir -p $INSTALL_DIR && cd $INSTALL_DIR
mkdir -p $LOGDIR && touch $TRANSPORTERRORLOGPATH
mkdir -p cluster
# To manage user configurations(indices, node)
echo "installing escue...."

IFS=',' read -ra packages <<< $INSTALL_PACKAGES
IFS=',' read -ra files <<< $INSTALL_FILES

for package in "${packages[@]}" ; do mkdir ${package}; cp -R "${script_dir}/${package}/" . ;done
for file in "${files[@]}" ; do cp $script_dir/$file . ; done

echo "Adding escue to bash command"
[[ ! -e $HOME/.bash_profile ]] && touch $HOME/.bash_profile

path_line_with_num=$(grep -n "PATH=*" $HOME/.bash_profile)
IFS=':' read -ra line_num <<< ${path_line_with_num}
origin_path=$(sed -n ''"${line_num}"' p' $HOME/.bash_profile)

if [ -z "$(grep $INSTALL_DIR $HOME/.bash_profile)" ]; then
  new_path=${origin_path}:${INSTALL_DIR}
  sed -i ''"${line_num}"' c '"${new_path}"'' $HOME/.bash_profile
fi
chmod a+rx escue
source $HOME/.bash_profile
echo "Install Complete"
