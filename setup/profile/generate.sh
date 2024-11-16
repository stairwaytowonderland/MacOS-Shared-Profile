#!/bin/sh

# Generates a combined profile

set -eu

if [ -f "$0" ]; then
  SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
else
  SCRIPT_DIR="$(pwd)"
fi

BASE_DIR="${BASE_DIR:-$(dirname $(dirname $SCRIPT_DIR))}"
UNAME="${UNAME:-$(uname -s)}"

FILE_NAME="${FILE_NAME:-dist/bashrc}"

[ -r "$BASE_DIR/etc/profile.d/02-functions.sh" ] && . "$BASE_DIR/etc/profile.d/02-functions.sh"

__generate_profile() {
  local file_name="${1:-$FILE_NAME}"
  local file_path="${BASE_DIR}/${file_name}"
  local base_path="$(dirname $file_path)"
  log_info "Generating profile from parts ..."
  if ! test -r "$base_path" ; then
    log_warn "Directory '$base_path' doesn't exist. Creating now ..."
    mkdir -p "$base_path" || true
  fi
  printf "#\n# This file was automatically generated from '%s'\n\n" $(echo "$0" | sed "s|${BASE_DIR}/||") \
    >"$file_path"
  for f in $(find "${BASE_DIR}/etc/profile.stub.d" -mindepth 1 -maxdepth 1 -type f -name '*.sh' ! -name '.*' | sort); do
    if [ "$f" = "${BASE_DIR}/etc/profile.stub.d/02-pieces.sh" ]; then
      for p in $(find "${BASE_DIR}/etc/profile.d" -mindepth 1 -maxdepth 1 -type f -name '*.sh' ! -name '.*' | sort); do
        log_info "  - Appending '$p'"
        printf "\n# -- BEGIN -- '%s'\n" $(echo "$p" | sed "s|${BASE_DIR}/||") >>"$file_path"
        printf "# ------------------------------------------------------------\n" >>"$file_path"
        is_debug || cat >>"$file_path" <"$p"
        printf "# ------------------------------------------------------------\n" >>"$file_path"
        printf "# -- END --\n" >>"$file_path"
      done
    else
        log_info "  - Appending '$f'"
        if [ "$f" = "${BASE_DIR}/etc/profile.stub.d/00-header.sh" ]; then
          is_debug || cat >>"$file_path" <"$f"
        else
          printf "\n" >>"$file_path"
          is_debug || cat >>"$file_path" <"$f"
        fi
    fi
  done
  log_success "Everything in it's right place"
}

main() {
  __generate_profile "${1:-$FILE_NAME}"
}

main "$@"
