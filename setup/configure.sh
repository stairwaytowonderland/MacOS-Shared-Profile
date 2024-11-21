#!/bin/bash

set -eu

if [ -f "$0" ]; then
  SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
else
  SCRIPT_DIR="$(pwd)"
fi

BASE_DIR="${BASE_DIR:-$(dirname $SCRIPT_DIR)}"
UNAME="${UNAME:-$(uname -s)}"

HOMEBREW_LEGACY_OS=false
HOMEBREW_DEFAULT_PREFIX=/opt/homebrew
HOMEBREW_LEGACY_PREFIX=/usr/local
HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-$HOMEBREW_DEFAULT_PREFIX}"
HOMEBREW_BREW_PATH="${HOMEBREW_PREFIX}/bin/brew"
HOMEBREW_BASH_PATH="${HOMEBREW_PREFIX}/bin/bash"

SHELL_CONFIGURED=false

__init() {
  # Homebrew path (brew --prefix / $HOMEBREW_PREFIX) is different on macOS 13.x and below
  if test "${HOMEBREW_LEGACY_OS:-false}" = "true" || \
    test "$(/usr/bin/sw_vers -productVersion | awk -F'.' '{print $1}')" -le "13" ; then
    (set -x; HOMEBREW_PREFIX="${HOMEBREW_LEGACY_PREFIX}") && \
      HOMEBREW_PREFIX="${HOMEBREW_LEGACY_PREFIX}"
  else
    (set -x; HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-$HOMEBREW_DEFAULT_PREFIX}") && \
      HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-$HOMEBREW_DEFAULT_PREFIX}"
  fi
  (set -x; HOMEBREW_BREW_PATH="${HOMEBREW_PREFIX}/bin/brew") && \
    HOMEBREW_BREW_PATH="${HOMEBREW_PREFIX}/bin/brew"
  (set -x; HOMEBREW_BASH_PATH="${HOMEBREW_PREFIX}/bin/bash") && \
    HOMEBREW_BASH_PATH="${HOMEBREW_PREFIX}/bin/bash"
}
__init

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
log_note() { logmsg note "$1"; }
log_info() { logmsg info "$1"; }
log_warn() { logmsg warn "$1"; }
log_success() { logmsg success "$1"; }
log_error() { logmsg error "$1"; }

# Everything Else

__download_homebrew() {
  command -v curl >/dev/null 2>&1 || abort "Curl required."
  if ! command -v "${HOMEBREW_BREW_PATH}" >/dev/null ; then
    log_info "Downloading 'homebrew' ..."
    [ "${DEBUG:-false}" = "true" ] || \
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  command -v "${HOMEBREW_BREW_PATH}" >/dev/null 2>&1 || return
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
  if command -v "${HOMEBREW_BREW_PATH}" >/dev/null ; then
    if ! command -v "${HOMEBREW_BASH_PATH}" >/dev/null ; then
      log_info "Installing brew 'bash' ..."
      [ "${DEBUG:-false}" = "true" ] || \
        $HOMEBREW_BREW_PATH install bash
    fi
    if [ "${SHELL}" != "${HOMEBREW_BASH_PATH}" ] ; then
      if sudo bash -cx "cat /etc/shells | grep '${HOMEBREW_BASH_PATH}'" >/dev/null 2>&1 ; then
        log_info "Appending '$HOMEBREW_BASH_PATH' to /etc/shells ..."
        [ "${DEBUG:-false}" = "true" ] || \
          (sudo bash -cx "echo $HOMEBREW_BASH_PATH >> /etc/shells")
      fi
      log_info "Changing shell to '$HOMEBREW_BASH_PATH' ..."
      [ "${DEBUG:-false}" = "true" ] || \
        (bash -cx "chsh -s '$HOMEBREW_BASH_PATH'")
      log_info "Loading necessary environment variables ..."
      [ "${DEBUG:-false}" = "true" ] || \
        (eval "$($HOMEBREW_BASH_PATH shellenv)"; shell="$HOMEBREW_BASH_PATH" bash -cx 'eval "export SHELL=$shell"')
    else
      log_warn "Brew 'bash' already installed at '$(ls $HOMEBREW_BASH_PATH)'."
      log_note "Use \`$HOMEBREW_BASH_PATH --version\` to check the version."
    fi
  else
    abort "Homebrew is required."
  fi
}

__configure_shell() {
  if ! test "${SHELL_CONFIGURED:-false}" = "true" ; then
    if test "${SHELL_ONLY:-false}" = "true" ; then
      __update_shell
    else
      __install_brew
      __update_shell
      log_success "Configure complete!"
      printf "\n\t%s\n\n" "You may now run \`make install\`"
    fi
    SHELL_CONFIGURED=true
  fi
}

# Main

main() {
  __options "$@"
  SHELL_ONLY="${2-false}" __configure_shell
}

__options() {
  while [ $# -gt 0 ]; do
    case "$1" in
      -h | --help) usage ;;
      -l | --legacy-os) HOMEBREW_LEGACY_OS="${2:-true}" __init; shift ;;
      -s | --shell-only) SHELL_ONLY="${2-false}" __configure_shell && exit $? || exit $? ;;
      *)
        log_warn "Unrecognized option: '$1'"
        usage 1
        ;;
    esac
    shift
  done
}

usage() {
  cat <<EOS
Configure Profile Installer
Usage: configure.sh [options]
    -h, --help       Display this message.
EOS
  exit "${1:-0}"
}

main "$@"
