#!/bin/bash

URL=$1
PROJECTS_PATH=$HOME/projects
#PROJECT_NAME=$(echo $URL | awk -F "/" '{print $5}' | awk -F "."  '{print $1}')
PROJECT_NAME=$(echo $URL  | grep -o '[^/]*$' | awk -F "."  '{print $1}') ##com grep
PROJECT_PATH=$PROJECTS_PATH/$PROJECT_NAME
DISTRO=$(cat /etc/*-release | grep ^ID= | cut -b4-)

function run_prerequisites(){
	install_essential_libs_$DISTRO

  git config credential.helper store
  
  if !(which asdf); then
    echo Instalando ASDF 
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf
    cd ~/.asdf
    git checkout "$(git describe --abbrev=0 --tags)"

    echo '. $HOME/.asdf/asdf.sh' >> ~/.bashrc
    echo '. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc
    echo 'legacy_version_file = yes' > ~/.asdfrc
    source ~/.bashrc
  fi
  asdf plugin add ruby
  asdf plugin add java 
  asdf plugin add nodejs
  asdf plugin add python
}

function download_project(){
  echo $PROJECT_PATH
  if [ ! -d $PROJECT_PATH ] 
  then 
    git clone $URL $PROJECT_PATH
  fi
  install_project_dependencies
}

function install_essential_libs_arch(){
  sudo pacman -S --needed curl git libffi libyaml openssl base-devel zlib >> /dev/null
}

function install_essential_libs_ubuntu(){
  sudo apt update
  ##https://github.com/rbenv/ruby-build/issues/1146
  #sudo apt install libssl-dev # Ruby versions > 2.4
  sudo apt install libssl1.0-dev # Ruby versions < 2.4
  #lib do mysql
  sudo apt install -y libmysqlclient-dev
  sudo apt install -y git curl zlib1g-dev autoconf bison build-essential libyaml-dev libreadline-dev libncurses5-dev libffi-dev libgdbm-dev
}

function install_project_dependencies(){
  cd $PROJECT_PATH && asdf install
  asdf current 1> temp_file 2>/dev/null
  programming_language=$(cat temp_file | awk '{print $1}')
  rm temp_file
  install_project_dependencies_$programming_language
}

function install_project_dependencies_ruby(){
  bundler_version=$(cat Gemfile.lock | grep -A 1 "BUNDLED WITH"| grep [0-9.-])
  cd $PROJECT_PATH && gem install bundler -v $bundler_version && bundle install
}

run_prerequisites
download_project