#!/bin/bash
OS_var=$(uname)
which brew
if [[ $? != 0 ]]; then
	if [[ "$OS_var" == "Linux" ]]; then
		echo "Install Linux Brew"
		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"
		PATH="$HOME/.linuxbrew/bin:$PATH"
		echo 'export PATH="$HOME/.linuxbrew/bin:$PATH"' >>~/.bash_profile
	elif [[ "$OS_var" == "Darwin" ]]; then
		echo "Install OSX Brew"
    		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
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
