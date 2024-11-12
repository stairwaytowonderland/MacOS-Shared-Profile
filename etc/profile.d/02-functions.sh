is_bool() {
  local true="${TRUE:-true}" false="${FALSE:-false}"
  case $1 in
    y|Y|yes|Yes|YES|n|N|no|No|NO|true|True|TRUE|false|False|FALSE|on|On|ON|off|Off|OFF|1|0) echo $true >&2;;
    *) echo $false >&2; return 1;;
  esac
}
is_true() {
  local true="${TRUE:-true}" false="${FALSE:-false}"
  case $1 in
    y|Y|yes|Yes|YES|true|True|TRUE|on|On|ON|1) echo $true >&2;;
    *) echo $false >&2; return 1;;
  esac
}
is_false() { is_bool $1 2>/dev/null && ! is_true $1 2>/dev/null  || return $?; }
is() { is_true $1 || return $?; }
is_interactive_mode() {
  # Ideally a redundant check since initial case statement should handle check for interactive mode
  echo $- | GREP_OPTIONS='' grep i >/dev/null
}
output() { ! is_interactive_mode || printf "\033[0;2m%s\033[0m\n" "$@"; }

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
