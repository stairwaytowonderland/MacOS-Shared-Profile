UMASK_OVERRIDE=0002
# Space separated e.g. '/path/one /path/two /path/three ...'
UMASK_OVERRIDE_DIRS='/Users/Shared'
UMASK_OVERRIDE_EXCLUDE_DIRS='/Users/Shared/Data'

export VISUAL="$HOME/.local/bin/bbeditor"
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

# Load ~/.env if it exists
[ ! -r ~/.env ] || . ~/.env
