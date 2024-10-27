#!/bin/sh

set -eu

if [ -f "$0" ]; then
  SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
else
  SCRIPT_DIR="$(pwd)"
fi

BASE_DIR="$(dirname $SCRIPT_DIR)"
UMASK_RESTORE="$(builtin umask)"

# https://specifications.freedesktop.org/basedir-spec/latest/
XDG_DATA_HOME=${XDG_DATA_HOME:="$HOME/.local/share"}

errcho() { >&2 echo $@; }

strip_last() {
  local str="$1" delimeter="${2:-.}" pattern="(.*)\.(.*)$"
  [ "$delimeter" = "." ] || pattern="(.*)${delimeter}(.*)$"
  [ -n "$str" ] && echo "$str" | sed -E "s/${pattern}/\1/"
}

__set_umask() { umask "${UMASK_DEFAULT:-$UMASK_RESTORE}"; }
__restore_umask() { umask "${UMASK_RESTORE}"; }

__confirm() {
  [ -n "${1:-""}" ] || return
  local msg="$1" input="" default="n" yn=""
  expr $input : '[yY]' >/dev/null 2>&1 && yn="[Y/n]" || yn="[y/N]"
  read -r -p $'\033[32;1m'"? "$'\033[0m'$'\033[1m'"$msg"$'\033[0m'" $yn " input
  [ -n "$input" ] || input="$default"
  expr $input : '[ynYN]' >/dev/null 2>&1 || __confirm "$msg"
  errcho $input
  expr $input : '[yY]' >/dev/null 2>&1 || return $?
}

__create_dir() {
  local dir="$1" group=staff
  if [ ! -r "$dir" ]; then
    printf "\033[1mCreating dir '%s'\033[0m\n" "$dir"
    mkdir -p "$dir"
    if __confirm "Reset group of '$dir' to '$group' (requires sudo)?" ; then
      printf "\033[1mResetting group of '%s' to '%s'\033[0m\n" "$dir" "$group"
      sudo chown ":${group}" "$dir"
    fi
  fi
}

__ensure_parent_dir() {
  local child="$1"
  local parent="$(dirname $child)"
  if [ ! -r "$parent" ]; then
     __set_umask
    __create_dir "$parent"
    __restore_umask
  fi
}

__create_symlink() {
  local source="$1" target="$2"
  __ensure_parent_dir "$target"
  if [ ! -r "$target" ]; then
    __set_umask
    printf "\033[1mCreating symlink '%s' => '%s'\033[0m\n" "$source" "$target"
    [ -r "$target" ] || ln -s "$source" "$target"
    __restore_umask
  fi
}

__copy_file() {
  local source="$1" target="$2"
  __ensure_parent_dir "$target"
  if [ ! -r "$target" ]; then
    __set_umask
    printf "\033[1mCopying '%s' to '%s'\033[0m\n" "$source" "$target"
    cp "$source" "$target"
    __restore_umask
  fi
}

__bin_files() {
  local source_dir="$1" target_dir="${2:-$1}" f=""
  [ -d "$source_dir" ] || return
  for f in $(find "$source_dir" -name '*.sh' -exec echo {} \;); do
    __create_symlink "$f" "${target_dir}/$(basename $(strip_last $f))"
  done
  unset f
}

__create_dirs_and_links() {
  __create_dir "${BASE_DIR}/Data"
  __bin_files "${BASE_DIR}/lib" "${BASE_DIR}/bin"
  __create_symlink "${BASE_DIR}/bin" "$(dirname $XDG_DATA_HOME)/bin"
  __create_symlink "${BASE_DIR}/etc/profile.d" "$(dirname $XDG_DATA_HOME)/profile.d"
  __create_symlink "${BASE_DIR}/.editorconfig" "$HOME/.editorconfig"
}

__copy_skel() {
  local f=""
  for f in $(find "${BASE_DIR}/etc/skel" -mindepth 1 -type f -name '.*' -exec echo {} \;); do
    __copy_file "$f" "$HOME/"
  done
  unset f
}

__install_crons() {
  printf "\033[1mUpdating crontab with: %s\033[0m\n" $(ls ${BASE_DIR}/cron/{.header,*.cron})
  cat ${BASE_DIR}/cron/{.header,*.cron} | crontab -
  printf "\033[1mUpdating root crontab with: %s\033[0m\n" $(ls ${BASE_DIR}/cron/root/{../.header,*.cron})
  cat ${BASE_DIR}/cron/root/{../.header,*.cron} | sudo crontab -
}

__gitconfig_nag() {
  printf "\033[1m%s\033[0m:\n\n\t%s\n\n... \033[1m%s\033[0m\n" \
    "Remember to generate your ssh keys" \
    "https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent" \
    "and update your ~/.gitconfig"
}

main() {
  __create_dirs_and_links
  __copy_skel
  __install_crons
  __gitconfig_nag
}

main "$@"
