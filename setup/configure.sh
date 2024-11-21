#!/bin/bash

set -eu

if [ -f "$0" ]; then
  SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
else
  SCRIPT_DIR="$(pwd)"
fi

BASE_DIR="${BASE_DIR:-$(dirname $SCRIPT_DIR)}"
UNAME="${UNAME:-$(uname -s)}"

SHELL_CONFIGURED=false

# Compatibility Check

HOMEBREW_BREW_PATH=""
HOMEBREW_BASH_PATH=""

# Homebrew path (brew --prefix / $HOMEBREW_PREFIX) is different on macOS 13.x and below
# Check official homebrew install.sh for updated paths: https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
__homebrew_compatibility() {
  local uname="${UNAME:-$(uname -s)}" uname_machine="${UNAME_MACHINE:-$(uname -m)}"
  local legacy_os="${HOMEBREW_LEGACY_OS:-false}" default_prefix="" legacy_prefix="" prefix=""
  local is_darwin=$(test "$uname" = "Darwin" && echo true || echo false)
  local is_linux=$(test "$uname" = "Linux" && echo true || echo false)
  local is_arm64=$(test "$uname_machine" = "arm64" && echo true || echo false)
  local is_x86_64=$(test "$uname_machine" = "x86_64" && echo true || echo false)

  if $is_darwin || $is_linux ; then
    if $is_darwin ; then
      default_prefix='/opt/homebrew'
      legacy_prefix='/usr/local'
      # If macOS is version 13.x or below, or running on an intel processor, then it's considered legacy
      (test "$(/usr/bin/sw_vers -productVersion | awk -F'.' '{print $1}')" -gt "13" && \
        $is_arm64) || legacy_os=true
    elif $is_linux && $is_x86_64 ; then # Homebrew on Linux currently only supported on intel processors
      default_prefix='/home/linuxbrew/.linuxbrew'
    fi
    if [ "${legacy_os:-false}" = "true" ]; then
      prefix="$legacy_prefix"
    else
      prefix="${HOMEBREW_PREFIX:-$default_prefix}"
    fi
    HOMEBREW_BREW_PATH="${prefix}/bin/brew"
    HOMEBREW_BASH_PATH="${prefix}/bin/bash"
    [ "${1:-false}" != "true" ] || >&2 echo "$prefix"
  fi
}

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
  [ "${DEBUG:-false}" = "true" ] && return
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
  __homebrew_compatibility
  __options "$@"
  SHELL_ONLY="${SHELL_ONLY:-false}" __configure_shell
}

__options() {
  while [ $# -gt 0 ]; do
    case "$1" in
      -h | --help) usage ;;
      -l | --legacy-os) HOMEBREW_LEGACY_OS=true __homebrew_compatibility ;;
      -s | --shell-only) SHELL_ONLY="${SHELL_ONLY:-true}" ;;
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
