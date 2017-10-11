#!/usr/bin/env bash
#global variables
OS_var=$(uname)
distro_var=$(cat /etc/os-release | head -n1)

#functions called throughout
function install_brew_osx() {
        echo "Installing OSX Brew"
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        echo "Finished function: install_brew_osx"
}

function install_brew_linux() {
        echo "Install Linux Brew"
        echo 'export PATH="$HOME/.linuxbrew/bin:$PATH"' >>~/.bashrc
        echo 'export MANPATH="$HOME/.linuxbrew/share/man:$MANPATH"' >>~/.bashrc
        echo 'export INFOPATH="$HOME/.linuxbrew/share/info:$INFOPATH"' >>~/.bashrc
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"
        source ~/.bashrc
        echo "Finished function: install_brew_linux"

}

function install_ruby_apt() {
        echo "Appears that Ruby is not installed: "
        sudo apt-get install ruby
        sudo apt install linuxbrew-wrapper
        echo "Finished function: install_ruby_apt"
}

function install_ruby_yum() {
        echo "Appears that Ruby is not installed: "
        sudo yum install ruby
        sudo yum groupinstall 'Development Tools'
        echo "Finished function: install_ruby_yum"
}

function get_package_list() {
        echo "Getting package list from site."
        DOWNLOAD_LIST_PACKAGE=$(wget --quiet -O - thisisrush.wordpress.com/brew-packages/ | grep '<br />' | awk -F '<' '{print $1","}')
        #echo "$DOWNLOAD_LIST_PACKAGE"
        declare -a LIST_PACKAGE
        IFS=','
        LIST_PACKAGE=($DOWNLOAD_LIST_PACKAGE)
        echo "The number of packages found were: ${#LIST_PACKAGE[@]}"
}

ruby --version
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
get_package_list
if [ -z "$LIST_PACKAGE" ]; then
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
fi
for PACKAGE in "${LIST_PACKAGE[@]}"
do
  OUTPUT=$(brew install "$PACKAGE" 2>&1)
  echo "$OUTPUT" | grep -i :
done
#V.1 - Includes brew update and check for brew.
#V.3 - Removed errors output.
#Rush Simonson
