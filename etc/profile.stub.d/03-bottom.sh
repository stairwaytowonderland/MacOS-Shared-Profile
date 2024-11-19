if test -x /opt/homebrew/bin/brew; then
  eval "$(/opt/homebrew/bin/brew shellenv)"

  export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d"
  test -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" && . "$(brew --prefix)/etc/profile.d/bash_completion.sh"
fi

# Display aliases (only output if interactive mode)
output "$(alias)"

! test -r "$(dirname $XDG_DATA_HOME)/bin" || export PATH="$(dirname $XDG_DATA_HOME)/bin:$PATH"
! test -r "$HOME/bin" || export PATH="$HOME/bin:$PATH"
