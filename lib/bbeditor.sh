#!/bin/sh

# /usr/local/bin/bbedit --wait --resume

__bbedit() {
    cmd="$(command -v bbedit)"
    [ -x "$cmd" ] && "$cmd" "$@" || return $?
}

if command -v launchctl >/dev/null && launchctl managername | grep "[A]qua" >/dev/null; then
  # GUI Enabled
  # /usr/local/bin/bbedit --wait $*
  __bbedit --wait --resume "$@" || nano "$@"
else
  # nano $*
  nano "$@"
fi
