#!/bin/sh

set -eu

bbwait() {
  if test -x "$(command -v bbedit)" ; then
    [ "root" != "$(whoami)" ] && \
      bbedit --language 'Unix Shell Script' \
        --create-unix \
        --new-window \
        --resume \
        --wait \
        -- "$@"
  else
    printf "ERROR: Can't find '%s'. Did you install the command line tools?\n" "bbedit"
  fi
}

main() {
  local err=0
  if command -v launchctl >/dev/null && launchctl managername | grep "[A]qua" >/dev/null; then
    # GUI Enabled
    bbwait "$@" || err=$?
    if [ $err -gt 0 ]; then
      case $err in
        *) nano -- "$@";;
      esac
    fi
  else
    nano -- "$@"
  fi
}

main "$@"
