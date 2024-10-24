# The .bashrc file should only be directly loaded for interactive non-login shells

${BASHRC_LOADED:-false} || BASHRC_LOADED=true

[ -r "/Users/Shared/etc/profile" ] && . "/Users/Shared/etc/profile"
