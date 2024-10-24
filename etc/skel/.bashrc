# The .bashrc file should only be directly loaded for interactive non-login shells

# Ensure no double load
if ! ${BASHRC_LOADED:-false} ; then
    BASHRC_LOADED=true

    if ! shopt login_shell >/dev/null ; then
        printf "\033[32;2;4m%s\033[0m\n" "This is an interactive non-login shell"
        cd ~
    fi

    [ -r "/Users/Shared/etc/profile" ] && . "/Users/Shared/etc/profile"
fi
