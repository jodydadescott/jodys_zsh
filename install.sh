#!/bin/bash -e
# shellcheck disable=SC2015
#


function main() {
  cd "$(dirname "$0")"
  install_antibody || { err "antibody install failed"; return 3; }
  install_spaceship || { err "spaceship install failed"; return 3; }
  install_zshrc || { err "zshrc install failed"; return 3; }
}

function install_antibody {

  [ -f /usr/local/bin/antibody ] && {
    err "antibody is already installed"
    return 0
  } ||:

  curl -o "${SCRATCH}/antibody" -sfL git.io/antibody
  chmod +x "${SCRATCH}/antibody"
  sudo "${SCRATCH}/antibody" -b /usr/local/bin
}

function install_spaceship() {
  [ -d "${HOME}/.spaceship" ] && {
    err "spaceship is already installed"
    return 0
  } ||:
  git clone https://github.com/spaceship-prompt/spaceship-prompt.git "${HOME}/.spaceship"
}

function install_zshrc() {

  local zsh_profile
  zsh_profile="$(pwd | sed "s#$HOME#\${HOME}#g")"

  [ -f "${HOME}/.zshrc" ] || {
    echo_zshrc "${zsh_profile}" > "${HOME}/.zshrc" || return 2
    err "${HOME}/.zshrc created"
    return 0
  }

  echo_zshrc "${zsh_profile}" > "${SCRATCH}/zshrc"

  diff "${HOME}/.zshrc" "${SCRATCH}/zshrc" > /dev/null 2>&1 && {
    err "no change to zshrc"
    return 0
  }

  local newname
  [ -f "${HOME}/.zshrc" ] && {
    newname="${HOME}/.zshrc.${RANDOM}"
    err "Moving ${HOME}/.zshrc to $newname"
    mv "${HOME}/.zshrc" "$newname"
    mv "${SCRATCH}/zshrc" "${HOME}/.zshrc"
    err "${HOME}/.zshrc created"
  } ||:

}

function echo_zshrc()
{
cat <<EOF
ZSH_PROFILE="${1}"
source \${ZSH_PROFILE}/entrypoint.zsh
EOF
}

function err() { echo "$@" 1>&2; }

SCRATCH="$(mktemp -d)"
trap _cleanup_scratch EXIT
function _cleanup_scratch { rm -rf "$SCRATCH"; }

main "$@"
