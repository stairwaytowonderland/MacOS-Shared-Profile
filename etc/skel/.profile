# Ensure no double load
${BASHRC_LOADED:-false} || BASHRC_LOADED=true
$BASHRC_LOADED && return

# Source everything from here to handle login and non-login shells the same
[ -n "$BASH" -a -r ~/.bashrc ] && . ~/.bashrc
