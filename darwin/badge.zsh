################################################################################
# Add a "badge" or watermark to Iterm2. By default the badge will show the
# logged in user and present working directory. The user may change the badge
# by typing "badge text". This will remain until the user types nobadge or the
# session ends. This is useful for demonstations with multiple windows.
# For example, if you are connected to two routers you can label them r1 and r2
# so that your audience is aware of which is which.
################################################################################

export ITERM2_BADGE_AUTO_UPDATE=1

function badge() {
  export ITERM2_BADGE_AUTO_UPDATE=0
  set_badge_text $@
  err "Use nobadge to restore";
}

function nobadge() {
  export ITERM2_BADGE_AUTO_UPDATE=1
  update_badge
}

function kbadge() {
  export KBADGE_ENABLED=true
  update_badge
}

function nokbadge() {
  export KBADGE_ENABLED=false
  update_badge
}

function update_badge() {
  [[ $ITERM2_BADGE_AUTO_UPDATE -eq 0 ]] && return
  local msg
  local dir
  dir=$PWD
  [[ "$HOME" == ${dir:0:${#HOME}} ]] && dir="~${dir:${#HOME}}"
  msg="${dir}"

  local kubecontext
  kubecontext=$(kubectl config current-context 2> /dev/null)
  [[ $kubecontext ]] && {
    msg+="\nk8s:$kubecontext"
    local kubens
    kubens=$(kubectl config view -o jsonpath="{.contexts[?(@.name == \"$kubecontext\")].context.namespace}")
    [[ "$kubens" ]] || { kubens="default"; }
    msg+=":$kubens"
  }
  set_badge_text ${msg}
}

function set_badge_text() {
  printf "\e]1337;SetBadgeFormat=%s\a" $(echo -n $@ | base64);
}

chpwd_functions+=(update_badge)
update_badge
################################################################################
