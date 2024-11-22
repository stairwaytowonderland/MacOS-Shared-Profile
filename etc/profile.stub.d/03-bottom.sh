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
