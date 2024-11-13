# Interactive Mode Check
is_interactive_mode() {
  # Ideally a redundant check since initial case statement should handle check for interactive mode
  echo $- | GREP_OPTIONS='' grep i >/dev/null
}

# Basic Output
output() { ! is_interactive_mode || printf "\033[0;2m%s\033[0m\n" "$@"; }
errcho() { >&2 echo $@; }

# Fancy Logging
logmsg() {
  local level="$1" msg="$2" label="${3:-""}" color_msg="${4:-$FALSE}" \
    label_code="${5:-""}" msg_code="${6:-""}" nc="\033[0m" label_color="" msg_color=""
  [ "${color_msg}" = "$TRUE" ] || color_msg="$FALSE"
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

# Boolean Checks
is_bool() {
  case $1 in
    y|Y|yes|Yes|YES|n|N|no|No|NO|true|True|TRUE|false|False|FALSE|on|On|ON|off|Off|OFF|1|0) errcho $TRUE >&2;;
    *) errcho $FALSE >&2; return 1;;
  esac
}
is_true() {
  case $1 in
    y|Y|yes|Yes|YES|true|True|TRUE|on|On|ON|1) errcho $TRUE >&2;;
    *) errcho $FALSE >&2; return 1;;
  esac
}
is_false() {
  local err=0
  is_bool $1 2>/dev/null && ! is_true $1 || err=$?
  [ $err -gt 0 ] && errcho $FALSE >&2 && return $err || errcho $TRUE >&2
}
is() { is_true $1 2>/dev/null || return $?; }

# Value Checks
equals() {
  local success="${FALSE:-false}"
  [ "$1" != "$2" ] || success="${TRUE:-true}" && errcho $success
  $success || return $?
}

# Shell System Checks
is_darwin() { uname -s | grep -i Darwin >/dev/null 2>&1 || return $?; }
is_linux() { uname -s | grep -i Linux >/dev/null 2>&1 || return $?; }
is_mingw64() { uname -s | grep -i MINGW64 >/dev/null 2>&1 || return $?; }
is_windows() { is_mingw64 || return $?; }

# Other Checks
is_debug() { is "${DEBUG:-$FALSE}" || return $?; }

# GNU Equivalents
__realpath() (
    local path=$1 file=''
    if [ ! -d "$path" ]; then
      file=/$(basename -- "$path")
      path=$(dirname -- "$path")
    fi
    path=$(cd -- "$path" && pwd)$file || return $?
    printf %s\\n "/${path#"${path%%[!/]*}"}"
)
command -v realpath >/dev/null || alias realpath='__realpath'
