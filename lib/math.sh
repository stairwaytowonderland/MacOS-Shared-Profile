#!/bin/sh

set -eu

__plus() {
  local value1="$1" value2="$2" dec="$3"
  awk -v dec="%.${dec}f" '{printf(dec"\n",$1+$2); exit(0) }' <<<"  $value1  $value2 "
  #awk -v a="$value1" -v b="$value2" -v dec="%.${dec}f" "BEGIN {printf dec\"\n\",(a+b); ; exit(0) }"
}

__minus() {
  local value1="$1" value2="$2" dec="$3"
  awk -v dec="%.${dec}f" '{printf(dec"\n",$1-$2); exit(0) }' <<<"  $value1  $value2 "
  #awk -v a="$value1" -v b="$value2" -v dec="%.${dec}f" "BEGIN {printf dec\"\n\",(a-b); ; exit(0) }"
}

__times() {
  local value1="$1" value2="$2" dec="$3"
  awk -v dec="%.${dec}f" '{printf(dec"\n",$1*$2); exit(0) }' <<<"  $value1  $value2 "
  #awk -v a="$value1" -v b="$value2" -v dec="%.${dec}f" "BEGIN {printf dec\"\n\",(a*b); ; exit(0) }"
}

__dividedby() {
  local value1="$1" value2="$2" dec="$3"
  awk -v dec="%.${dec}f" '{printf(dec"\n",$1/$2); exit(0) }' <<<"  $value1  $value2 "
  #awk -v a="$value1" -v b="$value2" -v dec="%.${dec}f" "BEGIN {printf dec\"\n\",(a/b); ; exit(0) }"
}

main() {
  local operation="${2-}" value1="${1-}" value2="${3-}" dec="${4:-2}"
  local err=0
  test $# -ge 3 || err=$?
  test $err -gt 0 && printf "Not enough args (%d required)\n" 3 && return $err || true && err=0
  if [ $# -gt 0 ]; then
    case $operation in
      '+') __plus "$value1" "$value2" "$dec" ;;
      '-') __minus "$value1" "$value2" "$dec" ;;
      '*') __times "$value1" "$value2" "$dec" ;;
      '/') __dividedby "$value1" "$value2" "$dec" ;;
      *) printf "Invalid operation: '%s'\n" "$operation"; return 1 ;;
    esac
  fi
}

main "$@"
