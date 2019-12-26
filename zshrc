function err() { echo $@ >&2; }

[[ $PROFILE ]] || { err "Missing required environment variable PROFILE"; return 0; }

uname=$(uname)

[ "$uname" = "Darwin" ] && { source ${PROFILE}/darwin/zshrc; return 0; }

[ "$uname" = "Linux" ] && { source ${PROFILE}/linux/zshrc; return 0; }

err "I dont know how to handle $uname"
