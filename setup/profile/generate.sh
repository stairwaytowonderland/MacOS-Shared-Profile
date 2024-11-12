#!/bin/sh

# Generates a combined profile

set -eu

if [ -f "$0" ]; then
  SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
else
  SCRIPT_DIR="$(pwd)"
fi

BASE_DIR="$(dirname $(dirname $SCRIPT_DIR))"
FILE_NAME=dist/bashrc
FILE_PATH="${BASE_DIR}/${FILE_NAME}"

errcho() { >&2 echo $@; }
is() { [ "${1:-false}" = "true" -o "${1:-0}" = "1" ] || return $?; }

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

__generate_profile() {
  logmsg info "Generating profile from parts ..."
  [ -r "${BASE_DIR}/dist" ] || mkdir "${BASE_DIR}/dist"
  printf "#\n# This file was automatically generated from '%s'\n" $(echo "$0" | sed "s|$HOME|\$HOME|") \
    >"$FILE_PATH"
  for f in $(find "${BASE_DIR}/etc/profile.stub.d" -mindepth 1 -maxdepth 1 -type f -name '*.sh' ! -name '.*' | sort); do
    if [ "$f" = "${BASE_DIR}/etc/profile.stub.d/02-pieces.sh" ]; then
      for p in $(find "${BASE_DIR}/etc/profile.d" -mindepth 1 -maxdepth 1 -type f -name '*.sh' ! -name '.*' | sort); do
        logmsg info "  - Appending '$p'"
        printf "\n# -- BEGIN -- '%s'\n" $(echo "$p" | sed "s|$HOME|\$HOME|") >>"$FILE_PATH"
        printf "# ------------------------------------------------------------\n" >>"$FILE_PATH"
        cat >>"$FILE_PATH" <"$p"
        printf "# ------------------------------------------------------------\n" >>"$FILE_PATH"
        printf "# -- END --\n" >>"$FILE_PATH"
      done
    else
        logmsg info "  - Appending '$f'"
        if [ "$f" = "${BASE_DIR}/etc/profile.stub.d/00-header.sh" ]; then
          cat >>"$FILE_PATH" <"$f"
        else
          printf "\n" >>"$FILE_PATH"
          cat >>"$FILE_PATH" <"$f"
        fi
    fi
  done
}

main() {
  __generate_profile
}

main "$@"
