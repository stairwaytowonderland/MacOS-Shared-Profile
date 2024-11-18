#!/bin/sh

set -eu

if [ -f "$0" ]; then
  SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
else
  SCRIPT_DIR="$(pwd)"
fi

BASE_DIR="${BASE_DIR:-$(dirname $SCRIPT_DIR)}"
UNAME="${UNAME:-$(uname -s)}"

# Basic Output

errcho() { >&2 echo -e "$@"; }

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

# Value Checks

is_equal() {
  local success="${FALSE:-false}"
  [ "$1" != "$2" ] || success="${TRUE:-true}"
  errcho $success
  $success || return $?
}
equals() { is_equal "$@" 2>/dev/null; }

# Fancy Logging

logmsg() {
  local level="$1" msg="$2" label="${3:-""}" color_msg="${4:-false}" \
    label_code="${5:-""}" msg_code="${6:-""}" nc="\033[0m" label_color="" msg_color=""
  [ "${color_msg}" = "true" ] || color_msg=false
  case $level in
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
log_info() { logmsg info "$1"; }
log_warn() { logmsg warn "$1"; }
log_success() { logmsg success "$1"; }
log_error() { logmsg error "$1"; }

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
