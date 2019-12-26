#!/bin/sh
set -e

cd $(dirname $0)

thisdir=$(pwd | sed -E "s-^$HOME($|(/.*))-~\2-")

echo "PROFILE=$thisdir
source \${PROFILE}/zshrc" > ~/.zshrc
