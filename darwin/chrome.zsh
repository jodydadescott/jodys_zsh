# Run Chrome with TLS/SSL key tracking enabled. This allows traffic to be
# decrypted even if PFS

function chrome.debug() {
	mkdir -p ${HOME}/.chrome
	export SSLKEYLOGFILE=${HOME}/.chrome/keylog
	/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome &
}
