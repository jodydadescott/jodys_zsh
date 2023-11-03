##!/bin/bash

function main() {
  install_antibody || { err "antibody install failed"; return 3; }
  install_spaceship || { err "spaceship install failed"; return 3; }
}

function install_antibody {
  scratch=$(mktemp -d)
  trap finish EXIT
  curl -o "${scratch}/antibody" -sfL git.io/antibody
  chmod +x "${scratch}/antibody"
  sudo "${scratch}/antibody" -b /usr/local/bin
}

function install_spaceship() {
  git clone https://github.com/spaceship-prompt/spaceship-prompt.git "${HOME}/.spaceship"
}

function finish { rm -rf "$scratch"; }
function err() { echo "$@" 1>&2; }

main "$@"
