#!/bin/sh

set -eu

if [ -f "$0" ]; then
  SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
else
  SCRIPT_DIR="$(pwd)"
fi

BASE_DIR="$(dirname $SCRIPT_DIR)"
UNAME="${UNAME:-$(uname -s)}"

[ -r "$BASE_DIR/etc/profile.d/02-functions.sh" ] && . "$BASE_DIR/etc/profile.d/02-functions.sh"

# https://specifications.freedesktop.org/basedir-spec/latest/
XDG_DATA_HOME="${XDG_DATA_HOME:=$HOME/.local/share}"
# Record the default umask value
UMASK_DEFAULT=0022
# Record the current umask value
UMASK_RESTORE=$(builtin umask)

strip_last() {
  local str="$1" delimeter="${2:-.}" pattern="(.*)\.(.*)$"
  [ "$delimeter" = "." ] || pattern="(.*)${delimeter}(.*)$"
  [ -n "$str" ] && echo "$str" | sed -E "s/${pattern}/\1/"
}

install_brewfile() {
  local brewfile="$BASE_DIR/setup/brew/Brewfile"
  local target="${1:-$brewfile}"
  is_debug || brew bundle --file="$target"
}

__set_umask() { umask $UMASK_DEFAULT; }
__restore_umask() { umask $UMASK_RESTORE; }

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
  local target="$1" group=staff
  if is "${UPDATE:-false}" || [ ! -r "$target" ]; then
    if __confirm "Directory '$target' doesn't exist. Create it?" "y" ; then
      log_info "Creating target '$target'"
      is_debug || mktarget -p "$target"
      if __confirm "Reset group of '$target' to '$group' (requires sudo)?" ; then
        log_info "Resetting group of '$target' to '$group'"
        is_debug || sudo chown ":${group}" "$target"
      fi
    fi
  else
    log_note "The target '$target' already exists."
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
  if __ensure_parent_dir "$target" ; then
    if is "${UPDATE:-false}" || [ ! -r "$target" ]; then
      is_debug || __set_umask
      log_info "Creating symlink '$source' => '$target'"
      is_debug || ln -s "$source" "$target"
      is_debug || __restore_umask
    else
      log_note "The target '$target' already exists."
    fi
  fi
}

__copy_file() {
  local source="$1" target="$2"
  if __ensure_parent_dir "$target" ; then
    if is "${UPDATE:-false}" || [ ! -r "$target" ]; then
      is_debug || __set_umask
      log_info "Copying '$source' to '$target'"
      is_debug || cp "$source" "$target"
      is_debug || __restore_umask
    else
      log_note "The target '$target' already exists."
    fi
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
  __create_bin "${BASE_DIR}/lib" "${BASE_DIR}/dist/bin"
  __create_symlink "${BASE_DIR}/dist/bin" "${BASE_DIR}/bin"
  __create_symlink "${BASE_DIR}/bin" "$(dirname $XDG_DATA_HOME)/bin"
  __create_symlink "${BASE_DIR}/etc/profile.d" "$(dirname $XDG_DATA_HOME)/profile.d"
  __create_symlink "${BASE_DIR}/.editorconfig" "$HOME/.editorconfig"
  __create_symlink "${BASE_DIR}/setup/brew/Brewfile" "$HOME/Brewfile"
}

__brewfile() {
  local brewfile="$1"
  if [ -r "$brewfile" ]; then
    ! __confirm "Install dependencies from Homebrew?" "y" || install_brewfile "$brewfile"
  fi
}

__configure_dependencies() {
  local brewfile="${HOME}/Brewfile"
  __create_dirs_and_links
  __brewfile "$brewfile"
}

__copy_skel_bash() {
  local target="${1:-"$HOME"}" sudo="${2:-false}" mode="" f=""
  ! is "$sudo" || mode=sudo
  for f in $(find "${BASE_DIR}/etc/skel" -mindepth 1 -type f -name '.*' ! -name '.env' ! -name '*.env' ! -name '.git*' -exec echo {} \;); do
    UPDATE="${UPDATE:-false}" $mode __copy_file "$f" "$target/$(basename $f)"
  done
  unset f
}

__copy_skel_env() {
  local target="${1:-"$HOME"}" sudo="${2:-false}" mode="" f=""
  ! is "$sudo" || mode=sudo
  for f in $(find "${BASE_DIR}/etc/skel" -mindepth 1 -type f -name '.env' -name '*.env' -exec echo {} \;); do
    UPDATE="${UPDATE:-false}" $mode __copy_file "$f" "$target/$(basename $f)"
  done
  unset f
}

__copy_skel_git() {
  local target="${1:-"$HOME"}" sudo="${2:-false}" mode="" f=""
  ! is "$sudo" || mode=sudo
  for f in $(find "${BASE_DIR}/etc/skel" -mindepth 1 -type f -name '.git*' -exec echo {} \;); do
    UPDATE="${UPDATE:-false}" $mode __copy_file "$f" "$target/$(basename $f)"
  done
  unset f
}

__copy_skel() {
  UPDATE="${UPDATE:-false}" __copy_skel_bash "$@"
  UPDATE="${UPDATE:-false}" __copy_skel_env "$@"
  UPDATE="${UPDATE:-false}" __copy_skel_git "$@"
}

__install_crons() {
  if is "${UPDATE:-false}" || __confirm "Install user crons?" "y" ; then
    log_info "Updating crontab with: $(ls ${BASE_DIR}/cron/{.header,*.cron})"
    is_debug || cat ${BASE_DIR}/cron/{.header,*.cron} | crontab -
  fi
}

__install_root_crons() {
  if is "${UPDATE:-false}" || __confirm "Install root crons (requires sudo)?" ; then
    printf "\033[1mUpdating root crontab with: %s\033[0m\n" $(ls ${BASE_DIR}/cron/root/{../.header,*.cron})
    is_debug || cat ${BASE_DIR}/cron/root/{../.header,*.cron} | sudo crontab -
  fi
}

__configure_root() {
  if __confirm "Configure 'root' user (requires sudo)?" "n" ; then
    if __confirm "Configure 'root' shell ($(command -v bash))?" "y" ; then
      is_debug || sudo chsh -s "$(command -v bash)"
    fi
    if __confirm "Configure 'root' profile?" "y" ; then
      __copy_skel /var/root "true"
    fi
  fi
}

__configure_profiles() {
  __copy_skel
  __install_crons
  __install_root_crons
  __configure_root
}

__gitconfig_nag() {
  printf "\033[1m%s\033[0m:\n\n\t%s\n\n... \033[1m%s\033[0m\n" \
    "Remember to generate your ssh keys" \
    "https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent" \
    "and update your ~/.gitconfig"
}

__main_cron() {
  UPDATE="${UPDATE:-false}" __install_crons
  UPDATE="${UPDATE:-false}" __install_root_crons
}

__main_basic_bash() {
  UPDATE="${UPDATE:-false}" __copy_skel_bash
}

__main_env() {
  UPDATE="${UPDATE:-false}" __copy_skel_env
}

__main_git() {
  UPDATE="${UPDATE:-false}" __copy_skel_git
}

__main_linux() {
  __configure_dependencies
  __configure_profiles
  __gitconfig_nag
}

__main_darwin() {
  __configure_dependencies
  __configure_profiles
  __gitconfig_nag
}

__main_windows() {
  __main_basic_bash
}

__main_update() {
  if [ $# -gt 0 ]; then
    case $1 in
      'bash') UPDATE=true __main_basic_bash;;
      'cron') UPDATE=true __main_cron;;
      'git') UPDATE=true __main_git;;
      'env') UPDATE=true __main_env;;
      *) ;;
    esac
  fi
}

__main_option_choice() {
  while [ $# -gt 0 ]; do
    case $1 in
      '-b'|'--bash-basic') __main_basic_bash;;
      '-c'|'--cron') __main_cron;;
      '-u'|'--update') __main_update "${2:-""}"; shift;;
      *) ;;
    esac
    shift
  done
}

__main_os_choice() {
  if is_linux ; then
    __main_linux
  elif is_darwin ; then
    __main_darwin
  elif is_windows ; then
    __main_windows
  else
    log_error "Unsupported system"
    return 1
  fi
}

main() {
  ! is_debug || log_warn "DEBUG is set to 'true' ... Output Only (hopefully)"
  if [ $# -gt 0 ]; then
    __main_option_choice "$@"
  else
    __main_os_choice
  fi
}

main "$@"
