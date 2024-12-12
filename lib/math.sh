#!/bin/sh

set -eu

MODE_QUIET=false
DEBUG="${DEBUG:-false}"
DEFAULT_PLACES=3
DECIMAL_PLACES=

# Arithmetic Operators

__plus() {
  local value1="$1" value2="$2" dec="$3"
  ([ "${DEBUG:-false}" != "true" ] || set -x; awk -v dec="%.${dec}f" '{printf(dec"\n",$1+$2); exit(0) }' <<<"  $value1  $value2 ")
  #awk -v a="$value1" -v b="$value2" -v dec="%.${dec}f" "BEGIN {printf dec\"\n\",(a+b); ; exit(0) }"
}

__minus() {
  local value1="$1" value2="$2" dec="$3"
  ([ "${DEBUG:-false}" != "true" ] || set -x; awk -v dec="%.${dec}f" '{printf(dec"\n",$1-$2); exit(0) }' <<<"  $value1  $value2 ")
  #awk -v a="$value1" -v b="$value2" -v dec="%.${dec}f" "BEGIN {printf dec\"\n\",(a-b); ; exit(0) }"
}

__times() {
  local value1="$1" value2="$2" dec="$3"
  ([ "${DEBUG:-false}" != "true" ] || set -x; awk -v dec="%.${dec}f" '{printf(dec"\n",$1*$2); exit(0) }' <<<"  $value1  $value2 ")
  #awk -v a="$value1" -v b="$value2" -v dec="%.${dec}f" "BEGIN {printf dec\"\n\",(a*b); ; exit(0) }"
}

__divides() {
  local value1="$1" value2="$2" dec="$3"
  ([ "${DEBUG:-false}" != "true" ] || set -x; awk -v dec="%.${dec}f" '{printf(dec"\n",$1/$2); exit(0) }' <<<"  $value1  $value2 ")
  #awk -v a="$value1" -v b="$value2" -v dec="%.${dec}f" "BEGIN {printf dec\"\n\",(a/b); ; exit(0) }"
}

__exp() {
  local value1="$1" value2="$2" dec="$3"
  ([ "${DEBUG:-false}" != "true" ] || set -x; awk -v dec="%.${dec}f" '{printf(dec"\n",$1^$2); exit(0) }' <<<"  $value1  $value2 ")
  #awk -v a="$value1" -v b="$value2" -v dec="%.${dec}f" "BEGIN {printf dec\"\n\",(a/b); ; exit(0) }"
}

__sqrt() {
  local value1="$1" dec="$2"
  ([ "${DEBUG:-false}" != "true" ] || set -x; awk -v dec="%.${dec}f" '{printf(dec"\n",sqrt($1)); exit(0) }' <<<"  $value1 ")
  #awk -v a="$value1" -v b="$value2" -v dec="%.${dec}f" "BEGIN {printf dec\"\n\",(a/b); ; exit(0) }"
}

# Comparison Operators

__eq() {
  local value1="${1-}" value2="${2-}"
  ([ "${DEBUG:-false}" != "true" ] || set -x; awk '{if ($1 == $2) exit(0); else exit(1)}' <<<"  $value1  $value2 ")
  # awk -v a="$value1" -v b="$value2" ' BEGIN { if ( a == b ) exit 0; else exit 1 } '
}

__ne() {
  local value1="${1-}" value2="${2-}"
  ([ "${DEBUG:-false}" != "true" ] || set -x; awk '{if ($1 != $2) exit(0); else exit(1)}' <<<"  $value1  $value2 ")
  # awk -v a="$value1" -v b="$value2" ' BEGIN { if ( a != b ) exit 0; else exit 1 } '
}

__gt() {
  local value1="${1-}" value2="${2-}"
  ([ "${DEBUG:-false}" != "true" ] || set -x; awk '{if ($1 > $2) exit(0); else exit(1)}' <<<"  $value1  $value2 ")
  # awk -v a="$value1" -v b="$value2" ' BEGIN { if ( a > b ) exit 0; else exit 1 } '
}

__ge() {
  local value1="${1-}" value2="${2-}"
  ([ "${DEBUG:-false}" != "true" ] || set -x; awk '{if ($1 >= $2) exit(0); else exit(1)}' <<<"  $value1  $value2 ")
  # awk -v a="$value1" -v b="$value2" ' BEGIN { if ( a >= b ) exit 0; else exit 1 } '
}

__lt() {
  local value1="${1-}" value2="${2-}"
  ([ "${DEBUG:-false}" != "true" ] || set -x; awk '{if ($1 < $2) exit(0); else exit(1)}' <<<"  $value1  $value2 ")
  # awk -v a="$value1" -v b="$value2" ' BEGIN { if ( a < b ) exit 0; else exit 1 } '
}

__le() {
  local value1="${1-}" value2="${2-}"
  ([ "${DEBUG:-false}" != "true" ] || set -x; awk '{if ($1 <= $2) exit(0); else exit(1)}' <<<"  $value1  $value2 ")
  # awk -v a="$value1" -v b="$value2" ' BEGIN { if ( a <= b ) exit 0; else exit 1 } '
}

# Main

__operation() {
  if test $# -ge 3 ; then
    local operator="${2-}" value1="${1-}" value2="${3-}" dec="${4:-$DEFAULT_PLACES}"
  elif test $# -ge 2 ; then
    local operator="${1-}" value1="${2-}" dec="${3:-$DEFAULT_PLACES}"
  fi
  test -n "$DECIMAL_PLACES" && test "$DECIMAL_PLACES" -gt "0" && dec="$DECIMAL_PLACES" || true
  case $operator in
    '+'|'plus') __argcheck 3 "$@" && __plus "$value1" "$value2" "$dec" || err=$? ;;
    '-'|'minus') __argcheck 3 "$@" && __minus "$value1" "$value2" "$dec" || err=$? ;;
    '*'|'times') __argcheck 3 "$@" && __times "$value1" "$value2" "$dec" || err=$? ;;
    '/'|'divides') __argcheck 3 "$@" && __divides "$value1" "$value2" "$dec" || err=$? ;;
    '^'|'exp') __argcheck 3 "$@" && __exp "$value1" "$value2" "$dec" || err=$? ;;
    'sqrt') __argcheck 2 "$@" && __sqrt "$value1" "$dec" || err=$? ;;
    *) err=2 ;;
  esac
  if test $err -ne 0 ; then
    printf "Invalid operator: '%s'\n" "$operator" >&2
    usage $err
  fi
}

__compare() {
  local value1="${1-}" operator="${2-}" value2="${3-}"
  local err=0 shopt_err="$(echo $- | egrep -o -q '[e]' && echo true || echo false)"
  local quiet_mode="${MODE_QUIET:-false}"
  case $operator in
    'eq'|'==') __argcheck 3 "$@" && __eq "$value1" "$value2" || err=$? ;;
    'ne'|'!=') __argcheck 3 "$@" && __ne "$value1" "$value2" || err=$? ;;
    'gt'|'>') __argcheck 3 "$@" && __gt "$value1" "$value2" || err=$? ;;
    'ge'|'>=') __argcheck 3 "$@" && __ge "$value1" "$value2" || err=$? ;;
    'lt'|'<') __argcheck 3 "$@" && __lt "$value1" "$value2" || err=$? ;;
    'le'|'<=') __argcheck 3 "$@" && __le "$value1" "$value2" || err=$? ;;
    *) err=2 ;;
  esac
  case $err in
    0) [ "${quiet_mode}" = "true" ] || echo true >&2; [ "true" != "${4:-false}" -a "true" != "${quiet_mode}" ] || return 0;;
    1) [ "${quiet_mode}" = "true" ] || echo false >&2; [ "true" != "${4:-false}" -a "true" != "${quiet_mode}" ] || return 1;;
    *) echo "Invalid comparison" >&2; usage $err ;;
  esac
}

__argcheck() {
  local expected="${1}" err=0; shift
  test $# -ge $expected || err=$?
  test $err -gt 0 && printf "Not enough args; expected: %d, received: %d\n" >&2 $expected $# && usage $err || true && err=0
}

usage() {
  cat <<'EOF'
Usage: math [OPTIONS] [ARGS]

Options:
  -q, --quiet          Suppress true/false output for comparison operations, and use exit codes (default: false)
  -d, --debug          Enable debug mode (default: false)
  -p, --places NUM     Set the number of decimal places (default: 3)
  -c, --compare        Compare two values
  -h, --help           Display this help message

Examples:
  math -p 4 1.2345 + 2.3456
  math --debug 10 / 2
  math -q -c 5 -eq 5
  math -c $(math 9 sqrt) == 3
EOF
  exit "${1:-0}"
}

# https://stackoverflow.com/questions/18761209/how-to-make-a-bash-function-which-can-read-from-standard-input
__main() {
  __argcheck 2 "$@"
  local err=0
  while [ $# -gt 1 ]; do
    case "${1-}" in
      '-q'|'--quiet') shift; MODE_QUIET=true; ;;
      '-d'|'--debug') shift; DEBUG=true; ;;
      '-p'|'--places') shift; DEFAULT_PLACES="$1"; shift ;;
      '-c'|'--compare') shift;
        __compare "$@";
        for arg in "$@"; do shift; done
        ;;
      '-h'|'--help') usage ;;
      *) __operation "$@";
        for arg in "$@"; do shift; done
        ;;
    esac
  done
}

__main "$@"
