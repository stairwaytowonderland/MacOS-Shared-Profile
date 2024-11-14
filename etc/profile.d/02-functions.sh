# Interactive Mode Check
is_interactive_mode() {
  # Ideally a redundant check since initial case statement should handle check for interactive mode
  echo $- | GREP_OPTIONS='' grep i >/dev/null
}

# Basic Output
errcho() { >&2 echo -e "$@"; }
output() { ! is_interactive_mode || errcho "\033[0;2m$@\033[0m"; }
flusherr() { output $?; }

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
    y|Y|yes|Yes|YES|n|N|no|No|NO|true|True|TRUE|false|False|FALSE|on|On|ON|off|Off|OFF|1|0) errcho $TRUE;;
    *) errcho $FALSE; return 1;;
  esac
}
is_true() {
  case $1 in
    y|Y|yes|Yes|YES|true|True|TRUE|on|On|ON|1) errcho $TRUE;;
    *) errcho $FALSE; return 1;;
  esac
}
is_false() {
  local err=0
  is_bool $1 >/dev/null 2>&1 && ! is_true $1 >/dev/null 2>&1 || err=$?
  [ $err -gt 0 ] && errcho $FALSE && return $err || errcho $TRUE
}
is() { is_true $1 2>/dev/null || return $?; }

# Value Checks
is_equal() {
  local success="${FALSE:-false}"
  [ "$1" != "$2" ] || success="${TRUE:-true}"
  errcho $success
  $success || return $?
}
equals() { is_equal "$@" 2>/dev/null; }

shellos() {
  test -r /etc/os-release && . /etc/os-release
  local uname="$(uname -s | awk -F'_' '{print $1}')"
  local id="" os="" os_like=""
  shopt -s nocasematch
  case $uname in
    Linux)
      # A slightly less targeted (but just as effective) approach is to source the /etc/os-release,
      # e.g. `test -r /etc/os-release && . /etc/os-release`
      if test -r /etc/os-release ; then
        local os_release_vars="ID ID_LIKE NAME"
        for var in $os_release_vars; do
          eval "$var="$(cat /etc/os-release | grep "^$var\=.*$" | awk -F'=' '{print $2}')
        done
        case $ID in
          ubuntu|rhel)
            id="$ID"
            os="$NAME"
            os_like="$ID_LIKE"
            ;;
          *) ;;
        esac
      fi
      ;;
    Darwin) os="$uname"; id=macos;;
    MINGW64) os="Windows"; id=windows;;
    *) ;;
  esac
  shopt -u nocasematch
  os="${id:+$id|}${os:-$uname}"
  os_like="${os_like:-$uname}"
  errcho "${uname}:${os}:${os_like}"
}

# Shell System Checks
is_linux() { equals "$(shellos 2>&1 | awk -F':' '{print $1}')" "Linux"; }
is_ubuntu() { shellos 2>&1 | awk -F'|' '{print $1}' | awk -F':' '{print $2}' | grep -i "ubuntu" >/dev/null 2>&1; }
is_rhel() { shellos 2>&1 | awk -F'|' '{print $1}' | awk -F':' '{print $2}' | grep -i "rhel" >/dev/null 2>&1; }
is_debian() { shellos 2>&1 | awk -F'|' '{print $2}' | awk -F':' '{print $1"."$2}' | grep -i "debian" >/dev/null 2>&1; }
is_fedora() { shellos 2>&1 | awk -F'|' '{print $2}' | awk -F':' '{print $1"."$2}' | grep -i "fedora" >/dev/null 2>&1; }
is_darwin() { shellos 2>&1 | awk -F':' '{print $1}' | grep -i "darwin" >/dev/null 2>&1; }
is_windows() { shellos 2>&1 | awk -F':' '{print $1}' | grep -i "mingw64" >/dev/null 2>&1; }

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
