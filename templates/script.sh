#!/bin/sh

set -eu

if [ -f "$0" ]; then
  SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
else
  SCRIPT_DIR="$(pwd)"
fi

BASE_DIR="$(dirname $SCRIPT_DIR)"

errcho() { >&2 echo $@; }

log() {
  local level="$1" msg="$2" label="${3:-""}" color_msg="${4:-false}"
  local nc="\033[0m" label_code=0 msg_code=0 label_color="" msg_color=""
  [ "${color_msg}" = "true" ] || color_msg=false
  case $level in
    info) label_code=94; label="${label:-INFO}";;
    warn) label_code=93; label="${label:-WARN}";;
    success) label_code=92; label="${label:-SUCCESS}";;
    error) label_code=91; label="${label:-ERROR}";;
    *) label_code=94; label="${label:-INFO}";;
  esac
  ! $color_msg || msg_code=$label_code
  label_color="\033[1;${label_code}m"; msg_color="\033[0;${msg_code}m"
  printf "${label_color}[ %s ]${nc} ${msg_color}%s${nc}\n" "$label" "$msg"
}

main() {

}

main "$@"
