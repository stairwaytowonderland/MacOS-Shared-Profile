#!/bin/sh

set -eu

if test -f "$0" ; then
  SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
elif test "${0#-}" = "bash" || test "${0#-}" = "zsh" ; then
  # The file is being sourced
  # BASH_SOURCE requires Bash
  # SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd)"
  # SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}")" >/dev/null 2>&1 && pwd)"
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")" >/dev/null 2>&1 && pwd -P)" # zsh compatible
else
  # The file is being sourced with 'sh'
  # For SCRIPT_DIR to be correct, the file must be sourced from it's containing directory
  SCRIPT_DIR=$(pwd -P)
fi

BASE_DIR="${BASE_DIR:-$(dirname $SCRIPT_DIR)}"
UNAME="${UNAME:-$(uname -s)}"

# Core

errcho() { >&2 printf "%s\n" "$@"; }
abort() {
  local err="$?"
  [ -n "${err}" -a "${err}" != "0" ] || err=1
  [ $# -gt 0 ] && errcho "$@" || errcho "There was a problem."
  exit $err
}

# Boolean Checks

is_bool() {
  case $1 in
    y|Y|yes|Yes|YES|n|N|no|No|NO|true|True|TRUE|false|False|FALSE|on|On|ON|off|Off|OFF|1|0) errcho true;;
    *) errcho false; return 1;;
  esac
}
is_true() {
  case $1 in
    y|Y|yes|Yes|YES|true|True|TRUE|on|On|ON|1) errcho true;;
    *) errcho false; return 1;;
  esac
}
is_false() {
  local err=0
  is_bool $1 2>/dev/null && ! is_true $1 || err=$?
  [ $err -gt 0 ] && errcho false && return $err || errcho true
}
is() { is_true $1 2>/dev/null || return $?; }

# Fancy Logging

logmsg() {
  local level="$1" msg="$2" label="${3:-""}" color_msg="${4:-false}" \
    label_code="${5:-""}" msg_code="${6:-""}" nc="\033[0m" label_color="" msg_color=""
  [ "$color_msg" = "true" ] || color_msg="false"
  case $level in
    note) label_code="${label_code:-95}"; label="${label:-NOTE}";;
    info) label_code="${label_code:-94}"; label="${label:-INFO}";;
    warn) label_code="${label_code:-93}"; label="${label:-WARN}";;
    success) label_code="${label_code:-92}"; label="${label:-SUCCESS}";;
    error) label_code="${label_code:-91}"; label="${label:-ERROR}";;
    *) label_code="${label_code:-0}"; label="${label:-$level}";;
  esac
  ! $color_msg || msg_code=$label_code
  label_color="\033[1;${label_code}m"; msg_color="\033[0;${msg_code}m"
  printf "${label_color}[ %s ]${nc} ${msg_color}%s${nc}\n" "$label" "$msg"
}
log_note() { logmsg note "$@"; }
log_info() { logmsg info "$@"; }
log_warn() { logmsg warn "$@"; }
log_success() { logmsg success "$@"; }
log_error() { logmsg error "$@"; }

# GNU Equivalents
__realpath() (
    local path=$1 file=''
    if [ ! -d "$path" ]; then
      file=/$(basename -- "$path")
      path=$(dirname -- "$path")
    fi
    path=$(cd -- "$path" && pwd)$file || return $?
    printf %s\\n "/${path#"${path%%[!/]*}"}"
)
command -v realpath >/dev/null || alias realpath='__realpath'

# Main Handlers

__main_option_choice() {
  while [ $# -gt 0 ]; do
    case $1 in
      '-o'|'--option') shift; printf "\033[4mArgs\033[0m\n"; printf "\t- %s\n" "$@";;
      *) ;;
    esac
    shift
  done
}

# Main

main() {
  log_success "Running '$0'"
  if [ $# -gt 0 ]; then
    __main_option_choice "$@"
  fi
}

main "$@"
