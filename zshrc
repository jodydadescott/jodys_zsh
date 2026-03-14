# Only run if in zsh
if [ -z "$ZSH_VERSION" ]; then
  # Not in zsh, skip all zsh-specific configuration
  # Set up minimal PATH for bash
  export PATH="/bin:/usr/bin:/usr/sbin:/sbin:/usr/local/bin"
  [ -z "$GOPATH" ] && export GOPATH=$HOME/.local/go/path
  [ -z "$GOROOT" ] && export GOROOT=$HOME/.local/go/root
  [ -d "$GOROOT/bin" ] && export PATH="$GOROOT/bin:$PATH"
  [ -d "$GOPATH/bin" ] && export PATH="$GOPATH/bin:$PATH"
  [ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"
  [ -d "/opt/homebrew/bin" ] && export PATH="/opt/homebrew/bin:$PATH"
  return 0 2>/dev/null || exit 0
fi

# We initially set the BASE_PATH. When addpath is called we will append the
# entry to PATH and TMP_PATH. Finally we will append the BASE_PATH to TMP_PATH
# and replace PATH with TMP_PATH.
BASE_PATH=/bin:/usr/bin:/usr/sbin:/sbin
PATH="$BASE_PATH"
export PATH

err() { echo "$@" 1>&2; }

[[ "$ZSH_PROFILE" ]] || {
  err "ZSH_PROFILE is not set"
  return 2 2>/dev/null || exit 2
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
  export PATH
}

TMP_PATH=""

function _addpath() {
  # Check for duplicates (works in both bash and zsh)
  if echo "$PATH" | tr ':' '\n' | grep -q "^$1$"; then
    err-debug "ignoring duplicate request to add path $1"
    return 0
  fi

  # Append to PATH and TMP_PATH
  if [ -n "$PATH" ]; then
    PATH="$PATH:$1"
  else
    PATH="$1"
  fi

  if [ -n "$TMP_PATH" ]; then
    TMP_PATH="$TMP_PATH:$1"
  else
    TMP_PATH="$1"
  fi
  return 0
}

# Zsh-specific configuration
if [ -n "$ZSH_VERSION" ]; then
  # Add custom completions directory to fpath
  fpath=(${HOME}/.zsh/completions $fpath)

  # Note: compinit is called AFTER modules load so fpath additions are included

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
fi


# Only load antidote in zsh
if [ -n "$ZSH_VERSION" ]; then
  source ${HOME}/.antidote/antidote.zsh
  [ -f "${HOME}/.zsh_plugins/common.zsh" ] && {
    source "${HOME}/.zsh_plugins/common.zsh"
  } || {
    err "WARNING: ${HOME}/.zsh_plugins/common.zsh not found. Run install.sh to generate it."
    antidote load ${ZSH_PROFILE}/plugins/common
  }
fi

function load_zshrcd() {
  [ -d "${ZSH_PROFILE}/zshrc.d" ] || {
    err "${ZSH_PROFILE}/zshrc.d does not exist"
    return 0
  }

  local os parts
  os="$(uname)"

  # In zsh, use lowercase conversion
  if [ -n "$ZSH_VERSION" ]; then
    os=${os:l}
  else
    # In bash, use tr
    os=$(echo "$os" | tr '[:upper:]' '[:lower:]')
  fi

  for f in $(/bin/ls -1 "${ZSH_PROFILE}/zshrc.d" | sort -t- -k1,1n); do
    # Skip if in bash and using zsh-specific syntax
    if [ -z "$ZSH_VERSION" ]; then
      # Simple pattern matching in bash
      if echo "$f" | grep -q "^[0-9]*-$os-"; then
        err-debug "loading $f"
        source "${ZSH_PROFILE}/zshrc.d/$f" || true
        continue
      fi
      if echo "$f" | grep -q "^[0-9]*-common-"; then
        err-debug "loading $f"
        source "${ZSH_PROFILE}/zshrc.d/$f" || true
        continue
      fi
      err-debug "ignoring $f"
    else
      # Original zsh syntax
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
    fi
  done
}

load_zshrcd

# Initialize completion system AFTER modules load (so fpath additions are included)
if [ -n "$ZSH_VERSION" ]; then
  autoload -Uz compinit
  typeset -i updated_at=$(date +'%j' -r ~/.zcompdump 2>/dev/null || stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)
  if [ $(date +'%j') != $updated_at ]; then
    compinit -i
  else
    compinit -C -i
  fi
  zmodload -i zsh/complist
fi

PATH="$TMP_PATH:$BASE_PATH"
export PATH
unset TMP_PATH

[ -f "$HOME/.zdebug" ] && {
  err "debug is enabled, use debug-disable to disable"
} ||:

export _ZO_DOCTOR=0
eval "$(zoxide init zsh)"
alias cd=z
