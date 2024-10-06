#!/bin/sh
if command -v launchctl >/dev/null && launchctl managername | grep "[A]qua" >/dev/null; then
  # GUI Enabled
  /usr/local/bin/bbedit -w $*
else
  nano $*
fi
