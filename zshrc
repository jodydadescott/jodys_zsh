err() { echo "$@" 1>&2; }

[[ "$ZSH_PROFILE" ]] || {
  err "ZSH_PROFILE is not set"
  exit 2
}

function debug-enable() { touch "$HOME/.zdebug"; }
function debug-disable() { rm -f "$HOME/.zdebug"; }

function err-debug() {
  [ -f "$HOME/.zdebug" ] || return 0
  err "$@"
}

function addpath() {
  for p in $@; do
    _addpath "$p"
  done
}

function _addpath() {
  echo -e "${TMP_PATH//:/"\n"}" | while read p ; do
  [[ "$p" == "$1" ]] && {
    err-debug "ignoring duplicate request to add path $p";
    return 0
  } ||:
  done
  [ -n "$TMP_PATH" ] && { TMP_PATH+=":$1"; } || { TMP_PATH="$1"; }
  return 0
}

# Add custom completions directory to fpath
fpath=(${HOME}/.zsh/completions $fpath)

autoload -Uz compinit
typeset -i updated_at=$(date +'%j' -r ~/.zcompdump 2>/dev/null || stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)
if [ $(date +'%j') != $updated_at ]; then
  compinit -i
else
  compinit -C -i
fi
zmodload -i zsh/complist

# Options
setopt extended_glob # enable extended glob patterns like (#i)
setopt auto_cd # cd by typing directory name if its not a command
setopt auto_list # automatically list choices on ambiguous completion
setopt auto_menu # automatically use menu completion
setopt always_to_end # move cursor to end if word had one match
setopt hist_ignore_all_dups # remove older duplicate entries from history
setopt hist_reduce_blanks # remove superfluous blanks from history items
setopt inc_append_history # save history entries as soon as they are entered
setopt share_history # share history between different instances
# setopt correct_all # autocorrect commands
setopt interactive_comments # allow comments in interactive shells

# Improve autocompletion style
# zstyle ':completion:*' menu select # select completions with arrow keys
# zstyle ':completion:*' group-name '' # group results by category
# zstyle ':completion:::::' completer _expand _complete _ignored _approximate # enable approximate matches for completion

# Keybindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[3~' delete-char
bindkey '^[3;5~' delete-char

PATH=/bin:/usr/bin

source ${HOME}/.antidote/antidote.zsh
antidote load ${ZSH_PROFILE}/plugins/common

function load_zshrcd() {
  [ -d "${ZSH_PROFILE}/zshrc.d" ] || {
    err "${ZSH_PROFILE}/zshrc.d does not exist"
    return 0
  }

  local os parts
  os="$(uname)"
  os=${os:l}

  for f in $(/bin/ls -1 "${ZSH_PROFILE}/zshrc.d" | sort -t- -k1,1n); do
    parts=(${(s/-/)f})
    [[ "$parts[2]" == (#i)"$os" ]] && {
      err-debug "loading $f"
      source "${ZSH_PROFILE}/zshrc.d/$f"
      continue
    } ||:

    [[ "$parts[2]" == "common" ]] && {
      err-debug "loading $f"
      source "${ZSH_PROFILE}/zshrc.d/$f"
      continue
    } ||:
      
    err-debug "ignoring $f"
  done
}

unset TMP_PATH
load_zshrcd
addpath /bin /usr/bin
export PATH="$TMP_PATH"
unset TMP_PATH

[ -f "$HOME/.zdebug" ] && {
  err "debug is enabled, use debug-disable to disable"
} ||:
