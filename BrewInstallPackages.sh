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
  if grep -q "linuxbrew" ~/.bashrc; then
    echo 'export PATH="$HOME/.linuxbrew/bin:$PATH"' >>~/.bashrc
    echo 'export MANPATH="$HOME/.linuxbrew/share/man:$MANPATH"' >>~/.bashrc
    echo 'export INFOPATH="$HOME/.linuxbrew/share/info:$INFOPATH"' >>~/.bashrc
  fi
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"
  source ~/.bashrc
  echo "Finished function: install_brew_linux"
}

function install_apt() {
  echo "Installing required packages: "
  sudo apt-get install ruby -y
  sudo apt-get install build-essential -y
  sudo apt install linuxbrew-wrapper -y
  echo "Finished function: install_apt"
}

function install_yum() {
  echo "Installing required packages: "
  sudo yum install ruby -y
  sudo yum groupinstall 'Development Tools' -y
  echo "Finished function: install_yum"
}

function get_package_list() {
  echo "Getting package list from site."
  DOWNLOAD_LIST_PACKAGE=$(curl -s -XGET https://thisisrush.wordpress.com/brew-packages/ | grep -vi 'site uses cookies' | grep '<br />' | awk -F '<' '{print $1","}')
  #echo "$DOWNLOAD_LIST_PACKAGE"
  declare -a LIST_PACKAGE
  IFS=','
  LIST_PACKAGE=($DOWNLOAD_LIST_PACKAGE)
  echo "The number of packages found were: ${#LIST_PACKAGE[@]}"
}

function check_or_install_ruby() {
  if ! ruby --version ; then
    if [[ "$OS_var" == "Linux" ]]; then
      if [[ "$distro_var" =~ ..Ubuntu ]]; then
        install_apt
      elif [[ "$distro_var" =~ CentOS.. ]]; then
        install_yum
      else
        echo "Sorry you will need to install Ruby and other required packages manually\nEx. sudo dnf install ruby"
        exit
      fi
    else
      echo "MacOS comes with Ruby"
    fi
  fi
}

function check_or_install_brew() {
  if ! which brew >/dev/null; then
    if [[ "$OS_var" == "Linux" ]]; then
      install_brew_linux
    elif [[ "$OS_var" == "Darwin" ]]; then
      install_brew_osx
    fi
  else
    brew update
  fi
}
function install_packages() {
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
  for PACKAGE in "${LIST_PACKAGE[@]}"; do
    OUTPUT=$(brew install "$PACKAGE" 2>&1)
    echo "$OUTPUT" | grep -i :
  done
}
function main() {
  check_or_install_ruby
  check_or_install_brew
  install_packages
}
main
