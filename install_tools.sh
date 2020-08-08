#!/bin/sh

main() {
  ( install_brew )
  ( install_aws )
}

install_brew() {
  local rc=0
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" || { err "Failed to install brew"; return 2; }
  _brew_install kubectl ||:
  _brew_install yasm ||:
  _brew_install telnet ||:
  brew install ffmpeg $(brew options ffmpeg | grep -vE '\s' | grep -- '--with-' | tr '\n' ' ') || { err "ffmpeg install failed"; }
}

_brew_install() {
  brew install $1 || { err "$1 install failed"; return 2; }
}

install_aws() {
  local tmp=$(mktemp -d) && cd $tmp
  curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
  unzip awscli-bundle.zip && sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws || { err "aws cli install failed"; }
  cd && rm -rf $tmp
}

main $@
