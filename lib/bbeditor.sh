#!/bin/sh

set -eu

# /usr/local/bin/bbedit --wait --resume

bbwait() {
  [ -x "$(command -v bbedit)" ] && [ "root" != "$(whoami)" ] && \
    bbedit --language 'Unix Shell Script' \
      --create-unix \
      --new-window \
      --resume \
      --wait \
      -- "$@"
}

main() {
  if command -v launchctl >/dev/null && launchctl managername | grep "[A]qua" >/dev/null; then
    # GUI Enabled
    # /usr/local/bin/bbedit --wait $*
    bbwait "$@" || nano -- "$@"
  else
    nano -- "$@"
  fi
}

main "$@"
