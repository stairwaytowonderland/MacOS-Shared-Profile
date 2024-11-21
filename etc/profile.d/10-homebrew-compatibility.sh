# Compatibility Check

HOMEBREW_BREW_PATH=""
HOMEBREW_BASH_PATH=""

# Homebrew path (brew --prefix / $HOMEBREW_PREFIX) is different on macOS 13.x and below
__homebrew_compatibility() {
  local legacy_os="${HOMEBREW_LEGACY_OS:-false}" default_prefix='/opt/homebrew' legacy_prefix='/usr/local'
  local prefix="${HOMEBREW_PREFIX:-$default_prefix}"
  if [ "$(uname -s)" = "Darwin" ] ; then
    test "$(/usr/bin/sw_vers -productVersion | awk -F'.' '{print $1}')" -gt "13" || HOMEBREW_LEGACY_OS=true
    [ "${legacy_os:-false}" != "true" ] || prefix="$legacy_prefix"
  fi
  HOMEBREW_BREW_PATH="${prefix}/bin/brew"
  HOMEBREW_BASH_PATH="${prefix}/bin/bash"
  [ "${1:-false}" != "true" ] || >&2 echo "$prefix"
}
__homebrew_compatibility
