#!/bin/bash

URL=$1
PROJECTS_PATH='~/my_projects'
PROJECT_NAME=$(echo $URL | awk -F "/" '{print $5}')
#PROJECT_NAME=$(echo $URL  | grep -o '[^/]*$') ##com grep
PROJECT_PATH=$PROJECTS_PATH/$PROJECT_NAME

function run_prerequisites(){
  git config credential.helper store
  sudo pacman -S --needed curl git libffi libyaml openssl base-devel zlib >> /dev/null

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
  git clone $URL $PROJECT_PATH
  install_project_dependencies
}

function install_project_dependencies(){
  cd $PROJECT_PATH && asdf install
  #TODO 
  #Criad um metodo que identifica o gerenciador de pacotes da linguagem, o instala, instala os pacotes 
  # e roda a aplicaçao 
  #&& bundle install >> /dev/null
}

run_prerequisites
download_project