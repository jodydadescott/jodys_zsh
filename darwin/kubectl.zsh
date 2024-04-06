source <(kubectl completion zsh)

# alias k=kubectl
function k() {
  [[ -p /dev/stdin ]] && {
    echo $(cat -) | kubectl "$@"
    rc=$?
    update_badge
    return "$rc"
  }

  kubectl "$@"
  rc=$?
  update_badge
  return "$rc"
}

function kset() {
  [[ "$1" ]] && {
    k config use-context "$1"
  } || {
    k config get-contexts --output=name
  }
}

function knset() {
  [[ "$1" ]] && {
    k config set-context --current --namespace="$1"
  } || {
    k get ns
  }
}
