#!/bin/bash
OS_var=$(uname)
distro_var=$(cat /etc/*-release | head -n1) 

#functions called throughout
function install_brew_osx() {
	echo "Installing OSX Brew"
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

function install_brew_linux() { 
	echo "Install Linux Brew"
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"
	PATH="$HOME/.linuxbrew/bin:$PATH"
	echo 'export PATH="$HOME/.linuxbrew/bin:$PATH"' >>~/.bashrc
}

function install_ruby_apt() {
	sudo apt-get install ruby
}

function install_ruby_yum() {
	sudo yum install ruby
}
which ruby
if [[ $? != 0 ]]; then 
	if [[ "$OS_var" == "Linux" ]]; then
		if [[ "$distro_var" =~ ..Ubuntu ]]; then
			install_ruby_apt
		elif [[ "$distro_var" =~ CentOS.. ]]; then
			install_ruby_yum
		else
			echo "Sorry you will need to install Ruby manually"
			echo "Ex. sudo dnf install ruby"
			exit
		fi
	else
		echo "MacOS comes with Ruby"
	fi
fi

which brew
if [[ $? != 0 ]]; then
	if [[ "$OS_var" == "Linux" ]]; then
		install_brew_linux
	elif [[ "$OS_var" == "Darwin" ]]; then
		install_brew_osx
	fi
else
    brew update
fi
declare -a LIST_PACKAGE=(
'coreutils'
'binutils'
'diffutils'
'watch'
'wget'
'bash'
'make'
'nano'
'python'
'python3'
'rsync'
'gnutls'
'grep'
'gnu-which'
'gnu-indent'
'gnu-sed'
'gnu-tar'
'nmap'
'tcptraceroute'
'ack'
'odt2txt'
'parallel'
'rsync'
'perl'
'googler'
'gawk'
'git'
'carthage'
'maven'
)
IFS=''
for PACKAGE in "${LIST_PACKAGE[@]}"
do
  OUTPUT=$(brew install $PACKAGE 2>&1)
  echo $OUTPUT | grep -i : | awk '{print $2,$3,$4}'
done
#V.1 - Includes brew update and check for brew.
#V.3 - Removed errors output.
#Rush Simonson
