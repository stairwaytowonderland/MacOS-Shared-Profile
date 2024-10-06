# Record the default umask value on the 1st run
[ -z "$DEFAULT_UMASK" ] && export DEFAULT_UMASK="$(builtin umask)"

_umask_hook() {
  if [ -n "$UMASK" -a "$UMASK" != "$DEFAULT_UMASK" ]; then
    umask "$UMASK"
  else
    umask "$DEFAULT_UMASK"
  fi
}

printf "\033[0;2m%s\033[0m: \033[91;2m%s\033[0m=>\033[92;2m%s\033[0m\n" "Overriding default umask" "$DEFAULT_UMASK" "$UMASK"

# Append `;` if PROMPT_COMMAND is not empty
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;}_umask_hook"