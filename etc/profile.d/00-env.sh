export UMASK_OVERRIDE=0002
# Space separated e.g. '/path/one /path/two /path/three ...'
export UMASK_OVERRIDE_DIRS=/Users/Shared

export VISUAL=~/bin/bbwait
export EDITOR="$VISUAL"
export GIT_EDITOR="$VISUAL"

# Enable colors in bash
export CLICOLOR=1
export LSCOLORS=GxBxCxDxexegedabagaced
export GREP_OPTIONS='--color=auto'
export GREP_COLORS='ms=01;31:mc=01;31:sl=:cx=:fn=35:ln=32:bn=32:se=36'

# Hides the default login message
export BASH_SILENCE_DEPRECATION_WARNING=1

# Load ~/.env if it exists
[ ! -r ~/.env ] || . ~/.env
