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

#MACOS_COREUTILS_ENABLED=false
#DIRCOLORS_ENABLED=true
#LOG_MESSAGING_ENABLED=true

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
