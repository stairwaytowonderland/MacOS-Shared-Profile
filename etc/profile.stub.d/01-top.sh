# If not running interactively, don't do anything
case $- in
  *i*) ;;
    *) return;;
esac

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# If not login shell, cd to home
shopt login_shell >/dev/null || cd ~
