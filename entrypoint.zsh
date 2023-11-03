err() { echo "$@" 1>&2; }

[[ "$ZSH_PROFILE" ]] || {
  err "ZSH_PROFILE is not set"
  exit 2
}

function addpath() {
  for p in $@; do
    PATH+=:${p}
  done
  export PATH
}

function source_dir() {
  [ -d ${1} ] && {
    for f in $( ls -1 ${1}); do
      [[ "$(echo "$f" | awk -F\. '{print $2}')" == "zsh" ]] && {
        # Dont load spaceship again
        [[ "$f" == "spaceship.zsh" ]] && continue ||:
        # err "Loading ${1}/${f}"
        source "${1}/${f}"
      }
    done
  } ||:
}

source "${ZSH_PROFILE}/$(uname | tr '[:upper:]' '[:lower:]')-entrypoint.zsh"
