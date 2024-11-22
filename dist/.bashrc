#
# This file was automatically generated from 'setup/profile/generate.sh'

########################################
# Bash Prompt Escape Sequence Reference
# (the below is just an example)
########################################

# \[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n\$

# # The first part sets the xterm title (usually shows in the titlebar of the window).

# \[        -Starts a sequence of escapes.
# \e]0;     -Starts the xterm title prompt expression.
# \w        -Display the current working directory.
# \a        -Equal to \007 (system bell).  In this case used to end the xterm title prompt.
# \]        -End escape sequence.

# # The second part sets the actual PS1 prompt

# \n        -Start with a newline.
# \[        -Start another sequence of escapes.
# \e[32m    -Sets the color to green.
# \]        -End escape sequence.

# \u@\h     -User at host name.  This and the \w below are the visible parts of the prompt.

# \[        -Begin another escape sequence.
# \e[33m    -Set color to red.
# \]        -End escape sequence.

# \w        -Display working directory in prompt.

# \[        -Begin another sequence.
# \e[0m     -Reset escape formatting to default.
# \]        -End sequence.

# \n        -Another newline.
# \$        -The final command line prompt character.

########################################
# For more information on prompt escape sequences, see:
# https://tldp.org/HOWTO/Bash-Prompt-HOWTO/bash-prompt-escape-sequences.html
# https://wiki.archlinux.org/title/Bash/Prompt_customization
########################################

# If not running interactively, don't do anything
case $- in
  *i*) ;;
    *) return;;
esac

# make less more friendly for non-text input files, see lesspipe(1)
test -x /usr/bin/lesspipe && eval "$(SHELL=/bin/sh lesspipe)"

# cd to home
shopt login_shell >/dev/null && [ "$PWD" = "$HOME" ] || cd ~

# -- BEGIN -- 'etc/profile.d/01-colors.sh'
# ------------------------------------------------------------
# define colors for easy reference
C_DEFAULT=$'\033[00m'; C_BOLD=$'\033[01m'; C_REVERSE=$'\033[07m'
C_RED=$'\033[00;31m'; C_GREEN=$'\033[00;32m'; C_YELLOW=$'\033[00;33m'
C_BLUE=$'\033[00;34m'; C_PURPLE=$'\033[00;35m'; C_CYAN=$'\033[00;36m'
C_RED_BOLD=$'\033[01;31m'; C_GREEN_BOLD=$'\033[01;32m'; C_YELLOW_BOLD=$'\033[01;33m'
C_BLUE_BOLD=$'\033[01;34m'; C_PURPLE_BOLD=$'\033[01;35m'; C_CYAN_BOLD=$'\033[01;36m'
# ------------------------------------------------------------
# -- END --

# -- BEGIN -- 'etc/profile.d/01-env.sh'
# ------------------------------------------------------------
# display fancy prompt error/success status, control_c message, and logout message
#FANCY_PROMPT=true

# show the error code alongside fancy prompt status
#FANCY_PROMPT_SHOW_ERROR_CODE=true

# reload .env file from 'PROMPT_COMMAND'
#PROMPT_COMMAND_ENV_RELOAD=true

# force __prompt_command to always be first when setting PROMPT_COMMAND
#PROMPT_COMMAND_ALWAYS_FIRST=false

# set force_color_prompt=true
#FORCE_COLOR_PROMPT=true

# umask override value for folders specified in UMASK_OVERRIDE_DIRS
#UMASK_OVERRIDE=0002

# insert new line before umask override status message
#UMASK_OVERRIDE_DISPLAY_MULTILINE=true

# UMASK_OVERRIDE_DIRS and UMASK_OVERRIDE_EXCLUDE_DIRS should be
# space separated, e.g. '/path/one /path/two /path/three ...'
#UMASK_OVERRIDE_DIRS='/Users/Shared'
#UMASK_OVERRIDE_EXCLUDE_DIRS='/Users/Shared/Data'

if [ -r "$HOME/.local/bin/bbeditor" ]; then
  export VISUAL="$HOME/.local/bin/bbeditor"
elif command -v code >/dev/null ; then
  export VISUAL="$(command -v code)"
elif command -v nano >/dev/null ; then
  export VISUAL="$(command -v nano)"
else
  export VISUAL="vi"
fi
export EDITOR="$VISUAL"
export GIT_EDITOR="$VISUAL"

# Enable colors in bash
export CLICOLOR=1
export LSCOLORS=GxBxCxDxexegedabagaced
# export GREP_OPTIONS='--color=auto' # Deprecated -- use option in alias
export GREP_COLORS='ms=01;31:mc=01;31:sl=:cx=:fn=35:ln=32:bn=32:se=36'

# Hides the default login message
export BASH_SILENCE_DEPRECATION_WARNING=1

# https://specifications.freedesktop.org/basedir-spec/latest/
export XDG_DATA_HOME=${XDG_DATA_HOME:="$HOME/.local/share"}

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# set variable identifying the chroot you work in (used in the prompt below)
# (for debian-based systems only; to check: `cat /etc/os-release | grep ID_LIKE | awk -F'=' '{print $2}'`)
# if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
#   debian_chroot=$(cat /etc/debian_chroot)
# fi

# Load ~/.env if it exists
[ ! -r ~/.env ] || . ~/.env
# ------------------------------------------------------------
# -- END --

# -- BEGIN -- 'etc/profile.d/02-functions.sh'
# ------------------------------------------------------------
# Interactive Mode Check
is_interactive_mode() {
  # Ideally a redundant check since initial case statement should handle check for interactive mode
  echo $- | GREP_OPTIONS='' grep i >/dev/null
}

# Basic Output
errcho() { >&2 echo -e "$@"; }
output() { ! is_interactive_mode || errcho "\033[0;2m$@\033[0m"; }
flusherr() { output $?; }

# Boolean Checks
is_bool() {
  case $1 in
    y|Y|yes|Yes|YES|n|N|no|No|NO|true|True|TRUE|false|False|FALSE|on|On|ON|off|Off|OFF|1|0) errcho true;;
    *) errcho false; return 1;;
  esac
}
is_true() {
  case $1 in
    y|Y|yes|Yes|YES|true|True|TRUE|on|On|ON|1) errcho true;;
    *) errcho false; return 1;;
  esac
}
is_false() {
  local err=0
  is_bool $1 >/dev/null 2>&1 && ! is_true $1 >/dev/null 2>&1 || err=$?
  [ $err -gt 0 ] && errcho false && return $err || errcho true
}
is() { is_true $1 2>/dev/null || return $?; }

# POSIX Compliant Decimal Comparison
# Simple decimal comparison function.
# Last (4th) argument defaults to false; Setting to true will cause
# the function to return 0 or 1 based on success or failure of the comparison,
# causing an error code of 1 if the comparison fails.
# Usage:
# testd <value1> <value2> <operator> [true|false]
# Example:
# testd 1.0 1.1 eq
# testd 1.0 1.1 eq false
testd() {
  local value1="${1-}"; shift
  local operator="${1-}"; shift
  local value2="${1-}"; shift
  local result=0 err=0
  case $operator in
    eq) result=$(echo "${value1}==${value2}" | bc); err=$?;;
    ne) result=$(echo "${value1}!=${value2}" | bc); err=$?;;
    gt) result=$(echo "${value1}>${value2}" | bc); err=$?;;
    ge) result=$(echo "${value1}>=${value2}" | bc); err=$?;;
    lt) result=$(echo "${value1}<${value2}" | bc); err=$?;;
    le) result=$(echo "${value1}<=${value2}" | bc); err=$?;;
    *) result=$(echo "${value1}=${value2}" | bc); err=$?;;
  esac
  [ $err -eq 0 ] || return $err
  case $result in
    1) errcho true; [ "true" != "${1:-false}" ] || return 0;;
    0) errcho false; [ "true" != "${1:-false}" ] || return 1;;
    *) errcho "Bad number"; return 3;;
  esac
}

# Designed to produce a decimal number version from a semantic version
# Usage:
# versiond "<a string with a semantic version in it>" [version index] [version string delimeter] [version number delimeter]
# Example:
# versiond "$(git --version)"
# versiond "$(git --version)" 3 . ' '
versiond() {
  local str="${1-}"
  echo "${str#v}" | awk -F"${4:- }" -v num="${2:-3}" '{print $num}' | awk -F"${3:-.}" '{print $1"."$2}'
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
log_note() { logmsg note "$@"; }
log_info() { logmsg info "$@"; }
log_warn() { logmsg warn "$@"; }
log_success() { logmsg success "$@"; }
log_error() { logmsg error "$@"; }

# Shell System Checks
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

is_linux() { equals "$(shellos 2>&1 | awk -F':' '{print $1}')" "Linux"; }
is_ubuntu() { shellos 2>&1 | awk -F'|' '{print $1}' | awk -F':' '{print $2}' | grep -i "ubuntu" >/dev/null 2>&1; }
is_rhel() { shellos 2>&1 | awk -F'|' '{print $1}' | awk -F':' '{print $2}' | grep -i "rhel" >/dev/null 2>&1; }
is_debian() { shellos 2>&1 | awk -F'|' '{print $2}' | awk -F':' '{print $1"."$2}' | grep -i "debian" >/dev/null 2>&1; }
is_fedora() { shellos 2>&1 | awk -F'|' '{print $2}' | awk -F':' '{print $1"."$2}' | grep -i "fedora" >/dev/null 2>&1; }
is_darwin() { shellos 2>&1 | awk -F':' '{print $1}' | grep -i "darwin" >/dev/null 2>&1; }
is_windows() { shellos 2>&1 | awk -F':' '{print $1}' | grep -i "mingw64" >/dev/null 2>&1; }

# Homebrew Compatibility Check

HOMEBREW_BREW_PATH=""
HOMEBREW_BASH_PATH=""

# Homebrew path (brew --prefix / $HOMEBREW_PREFIX) is different on macOS 13.x and below
# Check official homebrew install.sh for updated paths: https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
homebrew_compatibility() {
  local uname="$(uname -s)" uname_machine="$(uname -m)"
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

# Other Checks
is_debug() { is "${DEBUG:-false}" || return $?; }

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
# ------------------------------------------------------------
# -- END --

# -- BEGIN -- 'etc/profile.d/03-prompt.sh'
# ------------------------------------------------------------
# friendly logout message
quit() { printf "🤖 %s 🤖\n" "Klaatu barada nikto"; }

# 🚨 control_c handling
control_c() {
  local err="$?"
  printf "\n⛔ ${C_RED_BOLD}✗${C_DEFAULT} ${C_RED}(%s)${C_DEFAULT} ${C_BOLD}%s${C_DEFAULT} ⛔" "$err" "Operation cancelled by user"
  # To fully exit the script, use 'exit' instead of 'return'
  return $err;
}

# only run fancy control_c and friendly logout if FANCY_PROMPT is 'true'
if is "${FANCY_PROMPT:-false}" ; then
  trap quit EXIT
  trap control_c SIGINT SIGTERM SIGHUP
fi

# load .env file
load_env() { [ ! -r "$HOME/.env" ] || . "$HOME/.env"; }

# get current git branch
parse_git_branch() {
  is "${FANCY_PROMPT:-false}" && git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/' || true
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
! is "${FORCE_COLOR_PROMPT:-false}" || force_color_prompt=yes
! is_windows || force_color_prompt=yes

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

EXIT=0
__save_prompt_command() { _PROMPT_COMMAND=$PROMPT_COMMAND; }
__save_ps1() { _PS1=$PS1; }

# helper for quickly setting color
__ps1_color() {
  local _PS1_OPEN_ESC=$'\001'
  local _PS1_CLOSE_ESC=$'\002'
  local _PS1_FG="${1:-$C_DEFAULT}"
  echo "${_PS1_OPEN_ESC}${_PS1_FG}${_PS1_CLOSE_ESC}"
}

# display last exit code status
__exit_code_status() {
  local checkmark=✓ xmark=✗ checkmark_bold=✔ xmark_bold=✘ arrow_right=➜
  local code="${1:-0}" ps1_prompt_status=""
  if is "${FANCY_PROMPT:-false}" ; then
    if [ -z "$code" -o "$code" = "0" ]; then
      ps1_prompt_status="$(__ps1_color $C_GREEN)${checkmark_bold}$(__ps1_color) "
    else
      ps1_prompt_status="$(__ps1_color $C_RED_BOLD)${xmark_bold}$(__ps1_color) "
      # uncomment netx line to display exit the code
      ! is "${FANCY_PROMPT_SHOW_ERROR_CODE:false}" || ps1_prompt_status+="$(__ps1_color $C_RED)($code)$(__ps1_color) "
    fi
    printf "%s" "$ps1_prompt_status"
  fi
}

# display arguments
__prompt_args() { [ $# -eq 0 ] || printf "(%s) " "$@"; }
__title_status() { local code=${1:-0}; [ $code -eq 0 ] || printf "%s | " $code; }

# reload env
__prompt_command_env_reload() {
  if is "${PROMPT_COMMAND_ENV_RELOAD:-false}" ; then
    # always reload environment variables
    set -a; load_env; set +a >/dev/null
  fi
}

# Main function for updating $PROMPT_COMMAND
# if using this function to manipulate PS1, this function should always be first when setting PROMPT_COMMAND
__prompt_command() {
  # Cache initial exit code to avoid reset from env load
  local exit=${?##0}

  # load .env file before setting other vars
  __prompt_command_env_reload

  # Hack to always keep exit code up-to-date
  # TODO: this is needed because PS1_PREFIX seems to reset the error code .. why?
  EXIT=$exit
}

# Main function for updating $PS1
__ps1() {
  __exit_code_status $EXIT
  __prompt_args "$@"
}

if is "${PROMPT_COMMAND_ALWAYS_FIRST:-true}" ; then
  # ensure '__prompt_command' is first
  if [ -n "$PROMPT_COMMAND" ]; then
    PROMPT_COMMAND='__prompt_command "$@";'"$PROMPT_COMMAND"
  else
    PROMPT_COMMAND='__prompt_command "$@"'
  fi
else
  PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;}"'__prompt_command "$@"'
fi
__save_prompt_command

if is_linux ; then
  if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
  else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
  fi
else
  # Use 'parse_hostname' instead of '\h' for advanced customization
  if [ "$color_prompt" = "yes" ]; then
    PS1='$(__ps1_color $C_BLUE_BOLD)\u$(__ps1_color)@$(__ps1_color $C_GREEN_BOLD)$(parse_hostname 100 '-')$(__ps1_color):$(__ps1_color $C_BLUE_BOLD)\w$(__ps1_color $C_GREEN)$(parse_git_branch)$(__ps1_color)\$ '
  else
    PS1='\u@$(parse_hostname 100 '-'):\w$(parse_git_branch)\$ '
  fi
fi

! is "${FANCY_PROMPT:-false}" || PS1_PREFIX='\[\e]0;$(__title_status $?)$(__prompt_args "$@")\u@$(parse_hostname 100 '-'):\w\a\]'
PS1=${PS1_PREFIX:-""}'$(__ps1 "$@")'$PS1
__save_ps1
###

# cleanup
unset color_prompt force_color_prompt
# ------------------------------------------------------------
# -- END --

# -- BEGIN -- 'etc/profile.d/04-umask.sh'
# ------------------------------------------------------------
# Record the default umask value on the 1st run
UMASK_DEFAULT=0022 # $(builtin umask)
UMASK_OVERRIDE="${UMASK_OVERRIDE:-$UMASK_DEFAULT}"
UMASK_OVERRIDE_DIRS="${UMASK_OVERRIDE_DIRS:-""}"
UMASK_OVERRIDE_EXCLUDE_DIRS="${UMASK_OVERRIDE_EXCLUDE_DIRS:-""}"

__umask_default() {
  export UMASK=$UMASK_DEFAULT
}

__umask_override() {
  local prefix=""
  ! is "${UMASK_OVERRIDE_DISPLAY_MULTILINE:-false}" || prefix='\n'
  printf "$prefix\033[0;2m%s\033[0m: \033[91;2m%s\033[0m=>\033[92;2m%s\033[0m\n" "Overriding default umask" "$UMASK_DEFAULT" "$UMASK_OVERRIDE" >&2
  export UMASK=$UMASK_OVERRIDE
}

__umask_hook() {
  local flag=false
  if [ "$UMASK_OVERRIDE" != "$UMASK_DEFAULT" -a -n "$UMASK_OVERRIDE_DIRS" ]; then
    for d in $UMASK_OVERRIDE_DIRS; do
      if test -d "$d" ; then
        case $(realpath $PWD)/ in
          $d/*)
            if test -n "$UMASK_OVERRIDE_EXCLUDE_DIRS" ; then
              for e in $UMASK_OVERRIDE_EXCLUDE_DIRS; do
                [ "$(realpath $PWD)" = "$(realpath $e)" ] && flag=true && break || flag=false
              done
            fi
            $flag && __umask_default || __umask_override
            ;;
          *) __umask_default;;
        esac
      fi
    done
  fi
  [ -z "$UMASK" ] || umask "$UMASK"
}

# Append `;` if PROMPT_COMMAND is not empty
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;}"__umask_hook
__save_prompt_command
# ------------------------------------------------------------
# -- END --

# -- BEGIN -- 'etc/profile.d/05-aliases.sh'
# ------------------------------------------------------------
# Standard
alias ls='ls -G'
alias ll='ls -lahF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
# Custom
alias containerfy='cd ~/Tools/containerfy'
alias pwdr='realpath'
alias cdr='cd $(realpath)'
# ------------------------------------------------------------
# -- END --

test -n "${HOMEBREW_BREW_PATH}" || homebrew_compatibility

if test -x "${HOMEBREW_BREW_PATH}"; then
  eval "$($HOMEBREW_BREW_PATH shellenv)"

  if test "$(brew --prefix)/bin/brew" != "${HOMEBREW_BREW_PATH}" ; then
    log_error "'$(brew --prefix)/bin/bash' doesn't match '${HOMEBREW_BREW_PATH}'" "BREW_PREFIX_ERROR"
    test true = false || return
  fi

  export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d"
  test -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" && . "$(brew --prefix)/etc/profile.d/bash_completion.sh"
fi

# Display aliases (only output if interactive mode)
output "$(alias)"

! test -r "$(dirname $XDG_DATA_HOME)/bin" || export PATH="$(dirname $XDG_DATA_HOME)/bin:$PATH"
! test -r "$HOME/bin" || export PATH="$HOME/bin:$PATH"
