################################################################################
# Touchbar Bind utility for ZSH
################################################################################

# F1-12: https://github.com/vmalloc/zsh-config/blob/master/extras/function_keys.zsh

F1='^[OP'
F2='^[OQ'
F3='^[OR'
F4='^[OS'
F5='^[[15~'
F6='^[[17~'
F7='^[[18~'
F8='^[[19~'
F9='^[[20~'
F10='^[[21~'
F11='^[[23~'
F12='^[[24~'

fnKeys=($F1 $F2 $F3 $F4 $F5 $F6 $F7 $F8 $F9 $F10 $F11 $F12)

function touchbarBindF1() { pecho "\033]1337;SetKeyLabel=F1=$1\a"; bindkey -s $F1 "$2\n"; }
function touchbarBindF2() { pecho "\033]1337;SetKeyLabel=F2=$1\a"; bindkey -s $F2 "$2\n"; }
function touchbarBindF3() { pecho "\033]1337;SetKeyLabel=F3=$1\a"; bindkey -s $F3 "$2\n"; }
function touchbarBindF4() { pecho "\033]1337;SetKeyLabel=F4=$1\a"; bindkey -s $F4 "$2\n"; }
function touchbarBindF5() { pecho "\033]1337;SetKeyLabel=F5=$1\a"; bindkey -s $F5 "$2\n"; }
function touchbarBindF6() { pecho "\033]1337;SetKeyLabel=F6=$1\a"; bindkey -s $F6 "$2\n"; }
function touchbarBindF7() { pecho "\033]1337;SetKeyLabel=F7=$1\a"; bindkey -s $F7 "$2\n"; }
function touchbarBindF8() { pecho "\033]1337;SetKeyLabel=F8=$1\a"; bindkey -s $F8 "$2\n"; }
function touchbarBindF9() { pecho "\033]1337;SetKeyLabel=F9=$1\a"; bindkey -s $F9 "$2\n"; }
function touchbarBindF10() { pecho "\033]1337;SetKeyLabel=F10=$1\a"; bindkey -s $F10 "$2\n"; }
function touchbarBindF11() { pecho "\033]1337;SetKeyLabel=F11=$1\a"; bindkey -s $F11 "$2\n"; }
function touchbarBindF12() { pecho "\033]1337;SetKeyLabel=F12=$1\a"; bindkey -s $F12 "$2\n"; }

function pecho() { [ -n "$TMUX" ] && { echo -ne "\ePtmux;\e$*\e\\"; } || { echo -ne $*; } }

function touchbarReset() {
   for fnKey in "$fnKeys[@]"; do
      bindkey -s "$fnKey" ''
   done
   pecho "\033]1337;PopKeyLabels\a"
}

# The function displayTouch() should be overridden. The function
# touchbar.default() will restore the function to normal. We call it initially
# here.

touchbar.default() {
   function displayTouch() { touchbarReset; }
}
touchbar.default

# This function should be overridden
displayTouch() { touchbarReset; }

zle -N displayTouch

precmd_iterm_touchbar() { displayTouch; }

autoload -Uz add-zsh-hook
add-zsh-hook precmd precmd_iterm_touchbar

################################################################################
