test -n "${HOMEBREW_BREW_PATH}" || homebrew_compatibility

if test -x "${HOMEBREW_BREW_PATH}"; then
  eval "$($HOMEBREW_BREW_PATH shellenv)"

  if test "$(brew --prefix)/bin/brew" != "${HOMEBREW_BREW_PATH}" ; then
    log_error "'$(brew --prefix)/bin/bash' doesn't match '${HOMEBREW_BREW_PATH}'" "BREW_PREFIX_ERROR"
    test true = false || return
  fi

  export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d"
  test -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" && . "$(brew --prefix)/etc/profile.d/bash_completion.sh"
  if is "${MACOS_COREUTILS_ENABLED:-false}" && test -r "$(brew --prefix)/opt/coreutils/libexec/gnubin"; then
    log_note "Enabling GNU Core Utils from Homebrew, updating PATH (not recommended)"
    export PATH="$(brew --prefix)/opt/coreutils/libexec/gnubin:$PATH"
  fi
fi

! is_windows || DIRCOLORS_ENABLED=true

if is "${DIRCOLORS_ENABLED:-false}" && command -v dircolors >/dev/null 2>&1 ; then
  is "${DIRCOLORS_GENERATE_DB:-false}" || dircolors -p >"${HOME}/.dircolors"
  if test -r "${HOME}/.dircolors" ; then
    eval "$(dircolors -b ${HOME}/.dircolors)"
  elif test -r "/etc/DIR_COLORS" ; then
    eval "$(dircolors -b /etc/DIR_COLORS)"
  else
    eval "$(dircolors -b)"
  fi
fi

# Display aliases (only output if interactive mode)
output "$(alias)"

! test -r "$(dirname $XDG_DATA_HOME)/bin" || export PATH="$(dirname $XDG_DATA_HOME)/bin:$PATH"
! test -r "$HOME/bin" || export PATH="$HOME/bin:$PATH"
