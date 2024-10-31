#!/bin/sh

# Generates a combined profile

set -eu

if [ -f "$0" ]; then
  SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
else
  SCRIPT_DIR="$(pwd)"
fi

BASE_DIR="$(dirname $(dirname $SCRIPT_DIR))"

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

__generate_profile() {
  log info "Generating profile from parts ..."
  [ -r "${BASE_DIR}/dist" ] || mkdir "${BASE_DIR}/dist"
  printf "#\n# This file was automatically generated from '%s'\n" "$0" \
    >"${BASE_DIR}/dist/profile"
  for f in $(find "${BASE_DIR}/etc/profile.stub.d" -mindepth 1 -maxdepth 1 -type f -name '*.sh' ! -name '.*' | sort); do
    if [ "$f" = "${BASE_DIR}/etc/profile.stub.d/02-pieces.sh" ]; then
      for p in $(find "${BASE_DIR}/etc/profile.d" -mindepth 1 -maxdepth 1 -type f -name '*.sh' ! -name '.*' | sort); do
        log info "  - Appending '$p'"
        printf "\n# -- BEGIN -- '%s'\n" "$p" >>"${BASE_DIR}/dist/profile"
        cat >>"${BASE_DIR}/dist/profile" <"$p"
        printf "# -- END --\n" >>"${BASE_DIR}/dist/profile"
      done
    else
        log info "  - Appending '$f'"
        if [ "$f" = "${BASE_DIR}/etc/profile.stub.d/00-header.sh" ]; then
          cat >>"${BASE_DIR}/dist/profile" <"$f"
        else
          cat >>"${BASE_DIR}/dist/profile" <"$f"
        fi
    fi
  done
}

main() {
  __generate_profile
}

main "$@"
