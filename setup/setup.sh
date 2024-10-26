#!/bin/sh

if [ -f "$0" ]; then
  SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
else
  SCRIPT_DIR="$(pwd)"
fi

BASE_DIR="$(dirname $SCRIPT_DIR)"
XDG_DATA_HOME=${XDG_DATA_HOME:="$HOME/.local/share"}
UMASK_RESTORE="$(builtin umask)"

__set_umask() { umask "${UMASK_DEFAULT:-$UMASK_RESTORE}"; }
__restore_umask() { umask "${UMASK_RESTORE}"; }

__ensure_parent_dir() {
  local child="$1"
  local parent="$(dirname $child)"
  if [ ! -d "$parent" ]; then
    __set_umask
    printf "\033[1mCreating dir '%s'\033[0m\n" "$parent"
    mkdir -p "$parent"
    __restore_umask
  fi
}

create_symlink() {
  local source="$1" target="$2"
  __ensure_parent_dir "$target"
  if [ ! -r "$target" ]; then
    __set_umask
    printf "\033[1mCreating symlink '%s' => '%s'\033[0m\n" "$source" "$target"
    [ -r "$target" ] || ln -s "$source" "$target"
    __restore_umask
  fi
}

copy_file() {
  local source="$1" target="$2"
  __ensure_parent_dir "$target"
  if [ ! -r "$target" ]; then
    __set_umask
    printf "\033[1mCopying '%s' to '%s'\033[0m\n" "$source" "$target"
    cp "$source" "$target"
    __restore_umask
  fi
}

create_symlink "${BASE_DIR}/lib/bbwait.sh" "${BASE_DIR}/bin/bbwait"
create_symlink "${BASE_DIR}/lib/bbdiff.sh" "${BASE_DIR}/bin/bbdiff"
create_symlink "${BASE_DIR}/bin" "$(dirname $XDG_DATA_HOME)/bin"
create_symlink "${BASE_DIR}/etc/profile.d" "$(dirname $XDG_DATA_HOME)/profile.d"
create_symlink "${BASE_DIR}/.editorconfig" "$HOME/.editorconfig"

for f in $(find "${BASE_DIR}/etc/skel" -mindepth 1 -type f -name '.*' -exec echo {} \;); do
  copy_file $f "$HOME/"
done

printf "\033[1mUpdating crontab with: %s\033[0m\n" $(ls ${BASE_DIR}/cron/{.header,*.cron})
cat ${BASE_DIR}/cron/{.header,*.cron} | crontab -
printf "\033[1mUpdating root crontab with: %s\033[0m\n" $(ls ${BASE_DIR}/cron/root/{../.header,*.cron})
cat ${BASE_DIR}/cron/root/{../.header,*.cron} | sudo crontab -

printf "\033[1m%s\033[0m:\n\n\t%s\n\n... \033[1m%s\033[0m\n" "Remember to generate your ssh keys" "https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent" "and update your ~/.gitconfig"
