#!/bin/sh

set -eu

if test -x "$(command -v bbedit)" ; then
  # check stdin
  if test -t 0 ; then
    echo foo
    set -x
    bbedit -t "Temporary Document -- Please Save" --language "Unix Shell Script" --new-window --clean <<<"$@"
  else
    echo bar
    set -x
    bbedit -t "Temporary Document -- Please Save" --language "Unix Shell Script" --new-window --clean
  fi
else
  echo "ERROR: Can't find bbedit. Did you install the command line tools?"
fi
