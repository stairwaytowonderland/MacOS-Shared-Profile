# define colors for easy reference
C_DEFAULT=$'\033[00m'; C_BOLD=$'\033[01m'; C_REVERSE=$'\033[07m'
C_RED=$'\033[00;31m'; C_GREEN=$'\033[00;32m'; C_YELLOW=$'\033[00;33m'
C_BLUE=$'\033[00;34m'; C_PURPLE=$'\033[00;35m'; C_CYAN=$'\033[00;36m'
C_RED_BOLD=$'\033[01;31m'; C_GREEN_BOLD=$'\033[01;32m'; C_YELLOW_BOLD=$'\033[01;33m'
C_BLUE_BOLD=$'\033[01;34m'; C_PURPLE_BOLD=$'\033[01;35m'; C_CYAN_BOLD=$'\033[01;36m'

# 🚨
control_c() {
  local err="$?"
  printf "\n⛔ ${C_RED_BOLD}✗${C_DEFAULT} ${C_RED}(%s)${C_DEFAULT} ${C_BOLD}%s${C_DEFAULT} ⛔" "$err" "Operation cancelled by user"
  # To fully exit the script, use 'exit' instead of 'return'
  return $err;
}
if is "${FANCY_PROMPT:-false}" ; then
  trap control_c SIGINT SIGTERM SIGHUP
fi

# load .env file
load_env() { [ ! -r "$HOME/.env" ] || . "$HOME/.env"; }

# get current git branch
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export -f parse_git_branch

# custom hostname parsing
parse_hostname() {
  local arg=${1:-1} replace=${2:-.}
  local count=$(hostname | grep -o '\.' | wc -l | xargs echo)
  [ $count -gt 1 ] || arg=1
  hostname | sed -E 's/\.lan|\.local$//' | cut -d. -f1-$arg | sed "s/\./$replace/g"
}
export -f parse_hostname

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
  xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes
if is "${FORCE_COLOR_PROMPT_WINDOWS:-$FALSE}" ; then
  ! is_windows || force_color_prompt=yes
fi

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
  else
    color_prompt=
  fi
fi

### Custom PS1 and PROMPT_COMMAND Handling
__ps1_color() {
  local _PS1_OPEN_ESC=$'\001'
  local _PS1_CLOSE_ESC=$'\002'
  local _PS1_FG="${1:-$C_DEFAULT}"
  echo "${_PS1_OPEN_ESC}${_PS1_FG}${_PS1_CLOSE_ESC}"
}

# display last exit code status
__exit_code_status() {
  local checkmark=✓ xkmark=✗ checkmark_bold=✔ xmark_bold=✘ arrow_right=➜
  local code="${1:-0}" ps1_prompt_status=""
  if is "${FANCY_PROMPT:-false}" ; then
    if [ -z "$code" -o "$code" = "0" ]; then
      ps1_prompt_status="$(__ps1_color $C_GREEN)${checkmark_bold}$(__ps1_color) "
    else
      ps1_prompt_status="$(__ps1_color $C_RED_BOLD)${xmark_bold}$(__ps1_color) "
      # uncomment netx line to display exit the code
      #ps1_prompt_status+="$(__ps1_color $C_RED)($code)$(__ps1_color) "
    fi
    echo "$ps1_prompt_status"
  fi
}

__update_prompt_command() {
  local code=$? color_prompt="${1:-""}"
  local ps1_prompt_status="$(__exit_code_status $code)"
  set -a; load_env; set +a >/dev/null
}

PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;}__update_prompt_command"

if is_linux ; then
  if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
  else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
  fi
else
  # Use 'parse_hostname' instead of '\h' for advacned customization
  if [ "$color_prompt" = "yes" ]; then
    PS1="\[\033[01;34m\]\u\[\033[0m\]@\[\033[01;32m\]\$(parse_hostname 10 '-')\[\033[00m\]:\[\033[01;34m\]\w\[\033[0;32m\]\$(parse_git_branch)\[\033[00m\]\$ "
  else
    PS1="\u@\$(parse_hostname 10 '-'):\w\$(parse_git_branch)\$ "
  fi
fi
PS1='$(code=${?##0};__exit_code_status $code)'$PS1
###

# cleanup
unset color_prompt force_color_prompt
