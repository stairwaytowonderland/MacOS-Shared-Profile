FORCE_COLOR_PROMPT_WINDOWS=true

UMASK_OVERRIDE=0002
# Space separated e.g. '/path/one /path/two /path/three ...'
UMASK_OVERRIDE_DIRS='/Users/Shared'
UMASK_OVERRIDE_EXCLUDE_DIRS='/Users/Shared/Data'

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

export TRUE=true
export FALSE=false

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
# (for debian-based systems only)
# if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
#     debian_chroot=$(cat /etc/debian_chroot)
# fi

# Load ~/.env if it exists
[ ! -r ~/.env ] || . ~/.env
