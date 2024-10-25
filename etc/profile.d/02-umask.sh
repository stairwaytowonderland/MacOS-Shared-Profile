# Record the default umask value on the 1st run
[ -z "$DEFAULT_UMASK" ] && export DEFAULT_UMASK="$(builtin umask)"

_umask_hook() {
  if [ -n "$UMASK_OVERRIDE" -a "$UMASK_OVERRIDE" != "$DEFAULT_UMASK" ]; then
    for d in $UMASK_OVERRIDE_DIRS; do
      if [ "$PWD" = "$d" ]; then
        umask "$UMASK_OVERRIDE"
        printf "\033[0;2m%s\033[0m: \033[91;2m%s\033[0m=>\033[92;2m%s\033[0m\n" "Overriding default umask" "$DEFAULT_UMASK" "$UMASK_OVERRIDE"
      fi
    done
  else
    umask "$DEFAULT_UMASK"
  fi
}

# Append `;` if PROMPT_COMMAND is not empty
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;}_umask_hook"
