#!/bin/bash

set -eu

if [ -f "$0" ]; then
  SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
else
  SCRIPT_DIR="$(pwd)"
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

# Everything Else

__download_homebrew() {
  command -v brew >/dev/null 2>&1 || abort "Curl required."
  log_info "Downloading 'homebrew' ..."
  [ "${DEBUG:-false}" = "true" ] || \
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  command -v brew >/dev/null 2>&1 || return
}

__install_brew() {
  # First check OS.
  if [ "Darwin" = "${UNAME}" -o "Linux" = "${UNAME}" ]; then
    __download_homebrew || abort "Homebrew couldn't be installed."
  else
    abort "Homebrew is only supported on macOS and Linux."
  fi
}

__update_shell() {
  local shell='/opt/homebrew/bin/bash' flag=0
  if command -v brew >/dev/null ; then
    log_info "Installing brew 'bash' ..."
    [ "${DEBUG:-false}" = "true" ] || \
      brew install bash
    log_info "Appending '$shell' to /etc/shells ..."
    [ "${DEBUG:-false}" = "true" ] || \
      (sudo bash -cx "cat /etc/shells | grep '$shell'" || sudo bash -cx "echo $shell >> /etc/shells")
    log_info "Changing shell to '$shell' ..."
    [ "${DEBUG:-false}" = "true" ] || \
      (bash -cx "chsh -s '$shell'")
    log_info "Loading necessary environment variables ..."
    [ "${DEBUG:-false}" = "true" ] || \
      (eval "$($shell shellenv)"; shell="$shell" bash -cx 'eval "export SHELL=$shell"')
  else
    abort "Homebrew is required."
  fi
}

configure_shell() {
  __install_brew
  __update_shell
  log_success "Configure complete!"
  printf "\n\t%s\n\n" "You may now run \`make install\`"
}

# Main

main() {
  configure_shell
}

usage() {
  cat <<EOS
Configure Profile Installer
Usage: configure.sh [options]
    -h, --help       Display this message.
EOS
  exit "${1:-0}"
}

while [ $# -gt 0 ]; do
  case "$1" in
    -h | --help) usage ;;
    -s | --shell-only) configure_shell; exit 0;;
    *)
      log_warn "Unrecognized option: '$1'"
      usage 1
      ;;
  esac
  shift
done

main "$@"
