# Record the default umask value on the 1st run
UMASK_DEFAULT=0022 # $(builtin umask)
UMASK_OVERRIDE="${UMASK_OVERRIDE:-$UMASK_DEFAULT}"
UMASK_OVERRIDE_DIRS="${UMASK_OVERRIDE_DIRS:-""}"
UMASK_OVERRIDE_EXCLUDE_DIRS="${UMASK_OVERRIDE_EXCLUDE_DIRS:-""}"

__umask_default() {
  export UMASK=$UMASK_DEFAULT
}

__umask_override() {
  local prefix=""
  ! is "${UMASK_OVERRIDE_DISPLAY_MULTILINE:-false}" || prefix='\n'
  printf "$prefix\033[0;2m%s\033[0m: \033[91;2m%s\033[0m=>\033[92;2m%s\033[0m\n" "Overriding default umask" "$UMASK_DEFAULT" "$UMASK_OVERRIDE" >&2
  export UMASK=$UMASK_OVERRIDE
}

__umask_hook() {
  local flag=false
  if [ "$UMASK_OVERRIDE" != "$UMASK_DEFAULT" -a -n "$UMASK_OVERRIDE_DIRS" ]; then
    for d in $UMASK_OVERRIDE_DIRS; do
      if test -d "$d" ; then
        case $(realpath $PWD)/ in
          $d/*)
            if test -n "$UMASK_OVERRIDE_EXCLUDE_DIRS" ; then
              for e in $UMASK_OVERRIDE_EXCLUDE_DIRS; do
                [ "$(realpath $PWD)" = "$(realpath $e)" ] && flag=true && break || flag=false
              done
            fi
            $flag && __umask_default || __umask_override
            ;;
          *) __umask_default;;
        esac
      fi
    done
  fi
  [ -z "$UMASK" ] || umask "$UMASK"
}

# Append `;` if PROMPT_COMMAND is not empty
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;}"__umask_hook
__save_prompt_command
