# Ensure no double load
! ${BASHRC_LOADED:-false} && return

# If login shell display the calendar, else cd to home
shopt login_shell >/dev/null && cal || cd ~
