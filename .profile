for f in $(find /Users/Shared/etc/profile.d -mindepth 1 -maxdepth 1 -type f ! -name '.DS_Store' | sort); do
    . "$f"
done

eval "$(/opt/homebrew/bin/brew shellenv)"

export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d"
[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ] && . "$(brew --prefix)/etc/profile.d/bash_completion.sh"

