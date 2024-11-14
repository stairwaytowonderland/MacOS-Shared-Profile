#!/bin/sh

# Generates a combined profile

set -eu

if [ -f "$0" ]; then
  SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
else
  SCRIPT_DIR="$(pwd)"
fi

BASE_DIR="$(dirname $(dirname $SCRIPT_DIR))"
UNAME="${UNAME:-$(uname -s)}"

FILE_NAME=dist/bashrc
FILE_PATH="${BASE_DIR}/${FILE_NAME}"

export TRUE=true
export FALSE=false

[ -r "$BASE_DIR/etc/profile.d/02-functions.sh" ] && . "$BASE_DIR/etc/profile.d/02-functions.sh"

__generate_profile() {
  log_info "Generating profile from parts ..."
  [ -r "${BASE_DIR}/dist" ] || mkdir "${BASE_DIR}/dist"
  printf "#\n# This file was automatically generated from '%s'\n\n" $(echo "$0" | sed "s|${BASE_DIR}/||") \
    >"$FILE_PATH"
  for f in $(find "${BASE_DIR}/etc/profile.stub.d" -mindepth 1 -maxdepth 1 -type f -name '*.sh' ! -name '.*' | sort); do
    if [ "$f" = "${BASE_DIR}/etc/profile.stub.d/02-pieces.sh" ]; then
      for p in $(find "${BASE_DIR}/etc/profile.d" -mindepth 1 -maxdepth 1 -type f -name '*.sh' ! -name '.*' | sort); do
        log_info "  - Appending '$p'"
        printf "\n# -- BEGIN -- '%s'\n" $(echo "$p" | sed "s|${BASE_DIR}/||") >>"$FILE_PATH"
        printf "# ------------------------------------------------------------\n" >>"$FILE_PATH"
        cat >>"$FILE_PATH" <"$p"
        printf "# ------------------------------------------------------------\n" >>"$FILE_PATH"
        printf "# -- END --\n" >>"$FILE_PATH"
      done
    else
        log_info "  - Appending '$f'"
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
