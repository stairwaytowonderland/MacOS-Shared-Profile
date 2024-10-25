#!/bin/sh

# /usr/local/bin/bbdiff --wait --resume "$LOCAL" "$REMOTE"

__bbdiff() {
    cmd="$(command -v bbdiff)"
    [ -x "$cmd" ] && "$cmd" "$@" || return $?
}

if command -v launchctl >/dev/null && launchctl managername | grep "[A]qua" >/dev/null; then
  # GUI Enabled
  __bbdiff --wait --resume "$@" || diff "$@"
else
  diff "$@"
fi
