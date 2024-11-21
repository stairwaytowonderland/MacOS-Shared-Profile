# Compatibility Check

HOMEBREW_BREW_PATH=""
HOMEBREW_BASH_PATH=""

# Homebrew path (brew --prefix / $HOMEBREW_PREFIX) is different on macOS 13.x and below
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
__homebrew_compatibility
