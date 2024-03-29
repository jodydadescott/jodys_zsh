export OPENHAB_API="http://x1.thescottsweb.com:7080"
export OPENHAB_ITEM_OFFICE_LIGHT=officeSwitchDimmer1A
export OPENHAB_ITEM_OFFICE_LIGHT_DEFAULT=65

function light() {

  function _curl() {
    curl -X POST --header "Content-Type: text/plain" \
      --header "Accept: application/json" -d $1 \
      ${OPENHAB_API}/rest/items/${OPENHAB_ITEM_OFFICE_LIGHT}
  }

  level=$(echo $1 | tr '[:lower:]' '[:upper:]')
  [[ $level ]] || { err "Usage: light level (ON, OFF, 0-100)"; return 2; }
  [[ "$level" == "ON" ]] && { _curl $OPENHAB_ITEM_OFFICE_LIGHT_DEFAULT; return 0; }
  _curl $level
}
