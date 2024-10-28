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

info() {
  local str="$1"
  printf "\033[94;1m%s\033[0m \033[0m%s\033[0m\n" "[INFO]" "$str"
}

strip_last() {
  local str="$1" delimeter="${2:-.}" pattern="(.*)\.(.*)$"
  [ "$delimeter" = "." ] || pattern="(.*)${delimeter}(.*)$"
  [ -n "$str" ] && echo "$str" | sed -E "s/${pattern}/\1/"
}

install_brewfile() {
  local brewfile="$BASE_DIR/setup/brew/$(whoami).Brewfile"
  local target="${1:-$brewfile}"
  brew bundle --file="$target"
}

__set_umask() { umask "${UMASK_DEFAULT:-$UMASK_RESTORE}"; }
__restore_umask() { umask "${UMASK_RESTORE}"; }

__confirm() {
  [ -n "${1:-""}" ] || return
  local msg="$1" default="${2:-n}" yn="[y/N]" input=""
  expr $default : '[yY]' >/dev/null 2>&1 && yn="[Y/n]" || yn="[y/N]"
  read -r -p $'\033[32;1m'"? "$'\033[0m'$'\033[1m'"$msg"$'\033[0m'" $yn " input
  [ -n "$input" ] || input="$default"
  expr $input : '[ynYN]' >/dev/null 2>&1 || __confirm "$msg" "$default"
  errcho $input
  expr $input : '[yY]' >/dev/null 2>&1 || return $?
}

__create_dir() {
  local dir="$1" group=staff
  if [ ! -r "$dir" ]; then
    if __confirm "Directory '$dir' doesn't exist. Create it?" "y" ; then
      info "Creating dir '$dir'"
      mkdir -p "$dir"
      if __confirm "Reset group of '$dir' to '$group' (requires sudo)?" ; then
        info "Resetting group of '$dir' to '$group'"
        sudo chown ":${group}" "$dir"
      fi
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
    info "Creating symlink '$source' => '$target'"
    [ -r "$target" ] || ln -s "$source" "$target"
    __restore_umask
  fi
}

__copy_file() {
  local source="$1" target="$2"
  __ensure_parent_dir "$target"
  if [ ! -r "$target" ]; then
    __set_umask
    info "Copying '$source' to '$target'"
    cp "$source" "$target"
    __restore_umask
  fi
}

__create_bin() {
  local source_dir="$1" target_dir="${2:-$1}" f=""
  [ -d "$source_dir" ] || return
  for f in $(find "$source_dir" -name '*.sh' -exec echo {} \;); do
    __create_symlink "$f" "${target_dir}/$(basename $(strip_last $f))"
  done
  unset f
}

__create_dirs_and_links() {
  __create_dir "${BASE_DIR}/Data"
  __create_bin "${BASE_DIR}/lib" "${BASE_DIR}/bin"
  __create_symlink "${BASE_DIR}/bin" "$(dirname $XDG_DATA_HOME)/bin"
  __create_symlink "${BASE_DIR}/etc/profile.d" "$(dirname $XDG_DATA_HOME)/profile.d"
  __create_symlink "${BASE_DIR}/.editorconfig" "$HOME/.editorconfig"
  __create_symlink "${BASE_DIR}/setup/brew/$(whoami).Brewfile" "$HOME/Brewfile"
}

__brewfile() {
  local brewfile="$1"
  if [ -r "$brewfile" ]; then
    ! __confirm "Install dependencies from Homebrew?" "n" || install_brewfile "$brewfile"
  fi
}

__configure_dependencies() {
  local brewfile="${HOME}/Brewfile"
  __create_dirs_and_links
  __brewfile "$brewfile"
}

__copy_skel() {
  local target="${1:-"$HOME"}" mode="${2:-""}" f=""
  for f in $(find "${BASE_DIR}/etc/skel" -mindepth 1 -type f -name '.*' -exec echo {} \;); do
    $mode __copy_file "$f" "$target/"
  done
  unset f
}

__install_crons() {
  if __confirm "Install user crons?" "y" ; then
    info "Updating crontab with: $(ls ${BASE_DIR}/cron/{.header,*.cron})"
    cat ${BASE_DIR}/cron/{.header,*.cron} | crontab -
  fi
  if __confirm "Install root crons (requires sudo)?" ; then
    printf "\033[1mUpdating root crontab with: %s\033[0m\n" $(ls ${BASE_DIR}/cron/root/{../.header,*.cron})
    cat ${BASE_DIR}/cron/root/{../.header,*.cron} | sudo crontab -
  fi
}

__configure_root() {
  if __confirm "Configure 'root' user (requires sudo)?" "n" ; then
    ! __confirm "Configure 'root' shell ($(command -v bash))?" "y" || sudo chsh -s "$(command -v bash)"
    ! __confirm "Configure 'root' profile?" "y" || __copy_skel /var/root sudo
  fi
}

__configure_profiles() {
  __copy_skel
  __install_crons
  __configure_root
}

__gitconfig_nag() {
  printf "\033[1m%s\033[0m:\n\n\t%s\n\n... \033[1m%s\033[0m\n" \
    "Remember to generate your ssh keys" \
    "https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent" \
    "and update your ~/.gitconfig"
}

main() {
  __configure_dependencies
  __configure_profiles
  __gitconfig_nag
}

main "$@"
