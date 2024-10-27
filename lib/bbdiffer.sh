#!/bin/sh

set -eu

# /usr/local/bin/bbdiff --wait --resume "$LOCAL" "$REMOTE"

bbdiffer() { [ -x "$(command -v bbdiff)" ] && bbdiff --resume --wait -- "$@" || return $?; }

main() {
  if command -v launchctl >/dev/null && launchctl managername | grep "[A]qua" >/dev/null; then
    # GUI Enabled
    # TODO: Why does bbdiff always exits with exit code '1'?
    ! bbdiffer "$@"
  else
    diff -- "$@"
  fi
}

main "$@"
