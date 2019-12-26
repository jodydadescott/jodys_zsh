function err() { echo $@ >&2; }

[[ $PROFILE ]] || { err "Missing required environment variable PROFILE"; return 0; }

[ -f /etc/.jodymac ] && { source ${PROFILE}/mymac/zshrc; return 0; }

uname=$(uname)

[ "$uname" == "Linux" ] && { source ${PROFILE}/linux/zshrc; return 0; }
