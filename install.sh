#!/bin/sh

main()
{
cd $(dirname $0)

thisdir=$(pwd | sed -E "s-^$HOME($|(/.*))-~\2-")

echo "PROFILE=$thisdir
source \${PROFILE}/zshrc" > ~/.zshrc

zshell=$(which zsh)

[[ $(cat /etc/shells | grep "$zshell") ]] && {
  err "Shell $zshell is in /etc/shells"
} || {
  err "Shell $zshell is not in /etc/shells, adding. This will require sudo"
  echo $zshell | sudo tee -a /etc/shells
}

[[ "$SHELL" == "$zshell" ]] && {
  err "User shell is $zshell";
} || {
  err "User shell is $SHELL not $zshell; changing. This will require your password"
  chsh -s $zshell
}

}

err() { echo "$@" 1>&2; }

main $@
