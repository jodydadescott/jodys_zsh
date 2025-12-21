#!/bin/bash -e
# cSpell:ignore shellcheck reqs ZDOTDIR newname SCRATCH
# shellcheck disable=SC2015

function main() {
  install_reqs || { err "Failed"; return 3; }
  install_zshrc || { err "zshrc install failed"; return 3; }
  install_plugins || { err "plugin install failed"; return 3; }
}

function install_reqs() {
  cd "$(dirname "$0")" || { err "Failed to change dir"; return 2; }
  rm -rf "${HOME}/.antidote"
  rm -rf "${HOME}/.spaceship"
  git clone --depth=1 https://github.com/mattmc3/antidote.git "${ZDOTDIR:-$HOME}/.antidote"
  git clone --depth=1 https://github.com/spaceship-prompt/spaceship-prompt.git "${HOME}/.spaceship"
}

function install_plugins() {
  # Initialize antidote plugins to ~/.zsh-common (outside git repo)
  err "Installing antidote plugins to ~/.zsh-common..."
  zsh -c "source '${ZDOTDIR:-$HOME}/.antidote/antidote.zsh' && antidote bundle < '$(pwd)/plugins/common' > '${HOME}/.zsh-common'"
  err "Antidote plugins installed to ~/.zsh-common"
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
source \${ZSH_PROFILE}/zshrc
EOF
}

function err() { echo "$@" 1>&2; }

SCRATCH="$(mktemp -d)"
trap _cleanup_scratch EXIT
function _cleanup_scratch { rm -rf "$SCRATCH"; }

main "$@"
