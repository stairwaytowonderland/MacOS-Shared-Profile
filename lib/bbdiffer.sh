#!/bin/sh

set -eu

bbdiffer() {
  if test -x "$(command -v bbdiff)" ; then
    bbdiff --resume --wait -- "$@" || return $?
  else
    printf "ERROR: Can't find '%s'. Did you install the command line tools?\n" "bbedit"
  fi
}

main() {
  local err=0
  if command -v launchctl >/dev/null && launchctl managername | grep "[A]qua" >/dev/null; then
    # GUI Enabled
    bbdiffer "$@" || err=$?
    if [ $err -gt 0 ]; then
      case $err in
        1) printf "For some reason '%s' always exits with code 1.\n" "bbdiff" >&2;;
        *) diff -- "$@";;
      esac
    fi
  else
    diff -- "$@"
  fi
}

main "$@" 2>/dev/null
