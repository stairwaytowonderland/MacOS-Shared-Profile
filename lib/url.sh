#!/bin/sh

# eg: default profile name in UI might be "Abc", but its profile name is Default
# eg: another profile name in UI might be "Test Account", but its profile name might be "Profile 1"
# so identify the profiles names properly at ~/Library/Application\ Support/Google/Chrome

set -eu

GOOGLE_CHROME_BROWSER="Google Chrome"
BROWSER="${BROWSER:-$GOOGLE_CHROME_BROWSER}"

# Core

errcho() { >&2 printf "%s\n" "$@"; }
abort() {
  local err="$?"
  test "$err" -ne "0" || err=1
  [ $# -gt 0 ] && errcho "$@" || errcho "There was a problem."
  exit $err
}

# Value Checks

__is_email() { echo "${1-}" | egrep '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$'; }
__is_value() { [ -n "${1-}" -a "$(echo "${1-}")x" != "x" ] || return $?; }

# Helpers

__execute() {
  if __is_value "$user_profile" ; then
    echo "set -x; $com" | sudo su -l andrewh
  else
    eval "set -x; $com"
  fi
}

__open_chrome_profile_directory() {
  local url="${1}" chrome_profile="${2:-Default}" user_profile="${3-}"
  com="open -n -a \"${BROWSER}\" --args --profile-directory=\"${chrome_profile}\" \"--new-window\" \"${url}\""
  __execute "${com}"
}

__open_chrome_profile_email() {
  local url="${1}" chrome_profile="${2}" user_profile="${3-}"
  com="open -n -a \"${BROWSER}\" --args --profile-email=\"${chrome_profile}\" \"--new-window\" \"${url}\""
  __execute "${com}"
}

# Main

case $BROWSER in
  $GOOGLE_CHROME_BROWSER)
    if [ $# -gt 1 ]; then
      shopt -s nocasematch
      case ${2:-Default} in
        'stairwaytowonderland'|'Personal'|'Default') __open_chrome_profile_email "${1:-$HOME}" "stairwaytowonderland@gmail.com" "${3-}";;
        'andrewhaller101'|'Work'|'Profile 1') __open_chrome_profile_email "${1:-$HOME}" "andrewhaller101@gmail.com" "${3-}";;
        *)
          if __is_email "${2-}" ; then
            __open_chrome_profile_email "$@"
          else
            __open_chrome_profile_directory "$@"
          fi
        ;;
      esac
    else
      __open_chrome_profile_directory "${1:-$HOME}"
    fi
    ;;
  *) abort "Unsupported Browser: '$BROWSER'";;
esac
