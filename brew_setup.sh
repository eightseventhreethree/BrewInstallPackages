#!/usr/bin/env bash
#globals
OPERATING_SYSTEM=$(uname)
DISTRIBUTION=$(head -n1 /etc/os-release)
RUNASUSER=$(whoami)

#functions
function check_base_deps() {
  if ! which curl >/dev/null; then
    echo "Please install curl"; exit 1
  fi
  if ! which git >/dev/null; then
    echo "Please install git"; exit 1
  fi
}

function install_brew_osx() {
  echo "Installing OSX Brew"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  echo "Finished function: install_brew_osx"
}

function install_brew_linux() {
  echo "Install Linux Brew"
  if ! grep -q "linuxbrew" ~/.bashrc; then
    echo 'export PATH="$HOME/.linuxbrew/bin:$PATH"' >>~/.bashrc
    echo 'export MANPATH="$HOME/.linuxbrew/share/man:$MANPATH"' >>~/.bashrc
    echo 'export INFOPATH="$HOME/.linuxbrew/share/info:$INFOPATH"' >>~/.bashrc
  fi
  RBEXEC=$(which ruby)
  "${RBEXEC}" -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"
  source ~/.bashrc
  eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
  echo "Finished function: install_brew_linux"
}

function install_apt() {
  packages=('ruby' 'build-essential' 'linuxbrew-wrapper')
  echo "Installing required packages: ${packages[@]}"
  install_cmd="apt-get install "
  if ! [[ "root" =~ "${RUNASUSER}" ]]; then
    install_cmd="sudo ${install_cmd}"
  fi
  for package in "${packages[@]}"; do
    cmd="${install_cmd} ${package} -y"
    output=$(${cmd})
    echo "install output ${output}"
  done
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
  DOWNLOAD_LIST_PACKAGE=$(curl -s -L https://gist.githubusercontent.com/eightseventhreethree/e76c315843a7c78fd26e04326a405f3c/raw/packages.txt | awk -F '\n' '{print $1","}')
  declare -a LIST_PACKAGE
  IFS=','
  LIST_PACKAGE=(${DOWNLOAD_LIST_PACKAGE})
  echo "The number of packages found were: ${#LIST_PACKAGE[@]}"
}

function check_or_install_ruby() {
  if ! ruby --version ; then
    if [[ "$OPERATING_SYSTEM" == "Linux" ]]; then
      if [[ "$DISTRIBUTION" =~ ..Ubuntu ]]; then
        install_apt
      elif [[ "$DISTRIBUTION" =~ CentOS.. ]]; then
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
    if [[ "${OPERATING_SYSTEM}" == "Linux" ]]; then
      install_brew_linux
    elif [[ "${OPERATING_SYSTEM}" == "Darwin" ]]; then
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
  for package in "${LIST_PACKAGE[@]}"; do
    output=$(brew install "$package" 2>&1)
    echo "$output" | grep -i :
  done
}

function main() {
  check_base_deps
  check_or_install_ruby
  check_or_install_brew
  install_packages
}
main
