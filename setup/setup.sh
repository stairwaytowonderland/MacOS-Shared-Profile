#!/bin/sh

set -eu

if [ -f "$0" ]; then
  SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
else
  SCRIPT_DIR="$(pwd)"
fi

BASE_DIR="${BASE_DIR:-$(dirname $SCRIPT_DIR)}"
UNAME="${UNAME:-$(uname -s)}"

test -r "$BASE_DIR/etc/profile.d/01-colors.sh" && . "$BASE_DIR/etc/profile.d/01-colors.sh"
test -r "$BASE_DIR/etc/profile.d/02-functions.sh" && . "$BASE_DIR/etc/profile.d/02-functions.sh"

# https://specifications.freedesktop.org/basedir-spec/latest/
XDG_DATA_HOME="${XDG_DATA_HOME:=$HOME/.local/share}"

# Record the default umask value
UMASK=$(builtin umask)

strip_last() {
  local str="$1" delimeter="${2:-.}" pattern="(.*)\.(.*)$"
  [ "$delimeter" = "." ] || pattern="(.*)${delimeter}(.*)$"
  test -n "$str" && echo "$str" | sed -E "s/${pattern}/\1/"
}

install_brewfile() {
  local brewfile="$BASE_DIR/setup/brew/Brewfile"
  local target="${1:-$brewfile}"
  is_debug || brew bundle --file="$target"
}

__set_umask() { umask 0022; }
__restore_umask() { umask $UMASK; }

__confirm() {
  test -n "${1:-""}" || return
  local msg="$1" default="${2:-n}" yn="[y/N]" input=""
  expr $default : '[yY]' >/dev/null 2>&1 && yn="[Y/n]" || yn="[y/N]"
  read -r -p $'\033[32;1m'"? "$'\033[0m'$'\033[1m'"$msg"$'\033[0m'" $yn " input
  test -n "$input" || input="$default"
  expr $input : '[ynYN]' >/dev/null 2>&1 || __confirm "$msg" "$default"
  errcho $input
  expr $input : '[yY]' >/dev/null 2>&1 || return $?
}

__create_dir() {
  local target="$1" group=staff
  if is "${UPDATE:-false}" || ! test -r "$target"; then
    if __confirm "Directory '$target' doesn't exist. Create it?" "y" ; then
      log_info "Creating target '$target'"
      is_debug || test -r "$target" || mkdir -p "$target"
      if __confirm "Reset group of '$target' to '$group' and make group-writeable (requires sudo)?" ; then
        log_info "Resetting group of '$target' to '$group'"
        is_debug || sudo chown ":${group}" "$target"
        is_debug || sudo chmod g+w "$target"
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
    if is "${UPDATE:-false}" || ! test -r "$target"; then
      is_debug || __set_umask
      log_info "Creating symlink '$source' => '$target'"
      is_debug || test -r "$target" || ln -s "$source" "$target"
      is_debug || __restore_umask
    else
      log_note "The target '$target' already exists."
    fi
  fi
}

__copy_file() {
  local source="$1" target="$2"
  if __ensure_parent_dir "$target" ; then
    if is "${UPDATE:-false}" || ! test -r "$target"; then
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
  test -d "$source_dir" || return
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
    $mode __copy_file "$f" "$target/$(basename $f)"
  done
  unset f
}

__copy_skel_env() {
  local target="${1:-"$HOME"}" sudo="${2:-false}" mode="" f=""
  ! is "$sudo" || mode=sudo
  for f in $(find "${BASE_DIR}/etc/skel" -mindepth 1 -type f -name '.env' -name '*.env' -exec echo {} \;); do
    $mode __copy_file "$f" "$target/$(basename $f)"
  done
  unset f
}

__copy_skel_git() {
  local target="${1:-"$HOME"}" sudo="${2:-false}" mode="" f=""
  ! is "$sudo" || mode=sudo
  for f in $(find "${BASE_DIR}/etc/skel" -mindepth 1 -type f -name '.git*' -exec echo {} \;); do
    $mode __copy_file "$f" "$target/$(basename $f)"
  done
  unset f
}

__copy_skel() {
  __copy_skel_bash "$@"
  __copy_skel_git "$@"
  __copy_skel_env "$@"
}

__copy_dist() {
  local target="${1:-"$HOME"}" sudo="${2:-false}" mode="" f=""
  ! is "$sudo" || mode=sudo
  for f in $(find "${BASE_DIR}/dist" -mindepth 1 -type f -name '.*' -exec echo {} \;); do
    $mode __copy_file "$f" "$target/$(basename $f)"
  done
  unset f
}

__install_crons() {
  if is "${UPDATE:-false}" || __confirm "Install user crons?" "y" ; then
    log_info "Updating crontab with: $(ls ${BASE_DIR}/cron/{.header,*.cron})"
    is_debug || cat ${BASE_DIR}/cron/{.header,*.cron} | crontab -
  fi
}

__install_root_crons() {
  if is "${UPDATE:-false}" || __confirm "Install root crons (requires sudo)?" ; then
    printf "${C_BOLD}Updating root crontab with: %s${C_DEFAULT}\n" $(ls ${BASE_DIR}/cron/root/{../.header,*.cron})
    is_debug || cat ${BASE_DIR}/cron/root/{../.header,*.cron} | sudo crontab -
  fi
}

__configure_root() {
  if __confirm "Configure 'root' user (requires sudo)?" "n" ; then
    if is "${UPDATE:-false}" || __confirm "Configure 'root' shell ($(command -v bash))?" "y" ; then
      is_debug || sudo chsh -s "$(command -v bash)"
    fi
    if is "${UPDATE:-false}" || __confirm "Configure 'root' profile?" "y" ; then
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
  printf "${C_BOLD}%s${C_DEFAULT}:\n\n\t%s\n\n... ${C_BOLD}%s${C_DEFAULT}\n" \
    "Remember to generate your ssh keys" \
    "https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent" \
    "and update your ~/.gitconfig"
}

__git_commit() {
  local targets="$@" target=""
  local message="Updating skel files ..."
  git init "$HOME"
  for f in $targets; do
    target="${HOME}/$(basename $f)"
    message=$(cat <<EOF
$message
  - $f
EOF
)
    log_info "Staging '$target'"
    is_debug || git -C "$HOME" add "${HOME}/$(basename $f)" 2>/dev/null || true
    unset target
  done
  log_success "Committing with message: '$message'"
  is_debug || git -C "$HOME" commit -m "$message" 2>/dev/null || true
}

__git_status() {
  log_success "Retrieving \`git status\` from '$HOME'"
  is_debug || git -C "$HOME" status 2>/dev/null || true
}

__handle_basic_bash() {
  __copy_skel_bash
}

__handle_cron() {
  __install_crons
  __install_root_crons
}

__handle_env() {
  __copy_skel_env
}

__handle_git() {
  __copy_skel_git
}

__handle_root() {
  __configure_root
}

__handle_build() {
  __copy_skel "${BASE_DIR}/dist"
  __create_bin "${BASE_DIR}/lib" "${BASE_DIR}/dist/bin"
}

__handle_dist() {
  __copy_dist
}

__handle_linux() {
  __configure_dependencies
  __configure_profiles
  __gitconfig_nag
}

__handle_darwin() {
  __configure_dependencies
  __configure_profiles
  __gitconfig_nag
}

__handle_windows() {
  __handle_basic_bash
}

__main_git() {
  local primary="${1:-""}"
  while [ $# -gt 0 ]; do
    shift
    case $primary in
      'commit') shift; __git_commit "$@";;
      'status') __git_status;;
      *) ;;
    esac
  done
}

__main_install() {
  local primary="${1:-""}"
  if [ $# -gt 0 ]; then
    shift
    case $primary in
      'all') __configure_profiles;;
      'bash') __handle_basic_bash;;
      'cron') __handle_cron;;
      'dist') shift; __handle_dist "$@";;
      'env') __handle_env;;
      'git') __handle_git;;
      'root') __handle_root;;
      *) ;;
    esac
  fi
}

__main_option_choice() {
  local primary="${1:-""}"
  while [ $# -gt 0 ]; do
    shift
    case $primary in
      '-b'|'--build') UPDATE=true __handle_build;;
      '-c'|'--cron') __handle_cron;;
      '-g'|'--git') shift; __main_git "$@";;
      '-i'|'--install') secondary="${2:-""}"; shift; __main_install "$secondary";;
      '-u'|'--update') secondary="${2:-""}"; shift; UPDATE=true __main_install "$secondary" "$@";;
      *) ;;
    esac
  done
}

__main_os_choice() {
  if is_linux ; then
    __handle_linux
  elif is_darwin ; then
    __handle_darwin
  elif is_windows ; then
    __handle_windows
  else
    log_error "Unsupported system"
    return 1
  fi
}

main() {
  ! is_debug || log_warn "DEBUG is set to '$DEBUG'; ${C_BOLD}no actual changes should be made${C_DEFAULT}"
  if [ $# -gt 0 ]; then
    __main_option_choice "$@"
  else
    __main_os_choice
  fi
}

main "$@"
