#!/bin/sh

# Abstract:
#     Script for using BBEdit as the default EDITOR.
#
# Details:
#     This script allows BBEdit to be the `EDITOR` in a more robust way than
#     the `bbedit` command line tool allows. This is because the `bbedit`
#     command exits immediately after the file arguments are opened, unless the
#     `--wait` switch is used. However, some tools, such as crontab, fail with
#     a multiple-term `EDITOR`. This script can be set as the `EDITOR`,
#     resolving that issue. The `--resume` switch is also used, which returns
#     focus to the referring app (e.g., Terminal.app) after editing is complete.
#
# Usage:
#     Save this script to somewhere like your ~/bin directory. You can then put
#     something such as the following in your ~/.bashrc file::
#
#         # Set bbeditor as EDITOR.
#         if [ -f "$HOME/bin/bbeditor" ]; then
#             export EDITOR="$HOME/bin/bbeditor"
#         else
#             echo "WARNING: Can't find bbeditor."
#         fi
#

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
