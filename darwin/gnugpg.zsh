export GPG_TTY=$(tty)

function getgpgkey() {
  local gpg_pass_file="${HOME}/.ssh/gpg_passphrase"
  [ -f $gpg_pass_file ] || { err "File $gpg_pass_file not found"; return 2; }
  cat ${HOME}/.ssh/gpg_passphrase | pbcopy
  err "Passphrase is in buffer"
}
