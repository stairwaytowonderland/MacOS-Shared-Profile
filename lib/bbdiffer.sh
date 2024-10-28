#!/bin/sh

set -eu

bbdiffer() { [ -x "$(command -v bbdiff)" ] && bbdiff --resume --wait -- "$@" || return $?; }

main() {
  local err=0
  if command -v launchctl >/dev/null && launchctl managername | grep "[A]qua" >/dev/null; then
    # GUI Enabled
    bbdiffer "$@" || err=$?
    if [ $err -gt 0 ]; then
      case $err in
        1) printf "For some reason '%s' always exits with code 1.\n" "bbdiff";;
        *) diff -- "$@";;
      esac
    fi
  else
    diff -- "$@"
  fi
}

main "$@"
