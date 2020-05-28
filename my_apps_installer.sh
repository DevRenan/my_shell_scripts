#!/bin/bash

# Edite aqui os programas que deseja instalar com o gerenciador de pacotes universal SNAP
PROGRAMAS_PARA_INSTALAR=(
	rambox
	firefox
	chromium
	dbeaver-ce
	"code --classic"
	postman
	"teams-for-linux"
	zoom-client
  	"aws-cli --classic"
	onlyoffice-desktopeditors
)

function install_snap_arch(){
	sudo pacman -Syyu
	sudo pacman -S base-devel
	sudo pacman -S git
	cd /tmp
	git clone https://aur.archlinux.org/snapd.git
	cd snapd
	makepkg -si
	sudo systemctl enable --now snapd.socket
	sudo ln -s /var/lib/snapd/snap /snap
}

function install_snap_ubuntu(){
	sudo apt update
	sudo apt install snapd	
}

function test_snap(){
	sudo snap install hello-world && hello-world
}

function install_snap(){
	distro=$(cat /etc/*-release | grep ^ID= | cut -b4-)
	install_snap_$distro
	test_snap 	
}

function install_programs(){
	for (( i = 0; i < ${#PROGRAMAS_PARA_INSTALAR[@]}; i++)) do
		sudo snap install ${PROGRAMAS_PARA_INSTALAR[$i]}
	done
}

install_snap
install_programs
