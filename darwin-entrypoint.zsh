autoload -Uz compinit
typeset -i updated_at=$(date +'%j' -r ~/.zcompdump 2>/dev/null || stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)
if [ $(date +'%j') != $updated_at ]; then
  compinit -i
else
  compinit -C -i
fi
zmodload -i zsh/complist

# Options
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
# Load antibody plugin manager
source <(antibody init)
# Plugins
# antibody bundle buonomo/yarn-completion
antibody bundle zdharma/fast-syntax-highlighting
antibody bundle zsh-users/zsh-autosuggestions
antibody bundle zsh-users/zsh-history-substring-search
antibody bundle zsh-users/zsh-completions

[[ "$TERM_PROGRAM" == "iTerm.app" ]] && {
  antibody bundle marzocchi/zsh-notify
} ||:

# Keybindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[3~' delete-char
bindkey '^[3;5~' delete-char

source "${ZSH_PROFILE}/darwin/spaceship.zsh"
source_dir "${ZSH_PROFILE}/darwin"
source_dir "${ZSH_PROFILE}/common"

PATH=/usr/local/bin:$PATH
export PATH

# autoload -U +X bashcompinit && bashcompinit
