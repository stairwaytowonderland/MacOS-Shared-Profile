eval "$(/opt/homebrew/bin/brew shellenv)"

export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d"
[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ] && . "$(brew --prefix)/etc/profile.d/bash_completion.sh"

# Display aliases (only output if interactive mode)
output "$(alias)"

[ ! -r "$(dirname $XDG_DATA_HOME)/bin" ] || export PATH="$(dirname $XDG_DATA_HOME)/bin:$PATH"
