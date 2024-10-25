#!/bin/sh

if [ -f "$0" ]; then
  SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
else
  SCRIPT_DIR="$(pwd)"
fi

BASE_DIR="$(dirname $SCRIPT_DIR)"

create_symlink() {
  local source="$1" target="$2"
  [ -r "$target" ] || ln -s "$source" "$target"
}

copy_file() {
  local source="$1" target="$2"
  [ -r "$target" ] || cp "$source" "$target"
}

create_symlink "${BASE_DIR}/lib/bbwait.sh" "${BASE_DIR}/bin/bbwait"
create_symlink "${BASE_DIR}/lib/bbdiff.sh" "${BASE_DIR}/bin/bbdiff"
create_symlink "${BASE_DIR}/bin" ~/bin
create_symlink "${BASE_DIR}/etc/profile.d" ~/profile.d
create_symlink "${BASE_DIR}/.editorconfig" ~/.editorconfig

for f in $(find "${BASE_DIR}/etc/skel" -mindepth 1 -type f -name '.*' -exec echo {} \;); do
  printf "\033[1mCopying '%s' to ~ ...\033[0m\n" "$f"
  copy_file $f ~/
done

for f in $(find "${BASE_DIR}/etc/cron" -mindepth 1 -type f -name '*.sh' ! -name 'sudo-*.sh' -exec echo {} \;); do
  printf "\033[1mAdding '%s' to crontab ...\033[0m\n" "$f"
  crontab "$f"
done

for f in $(find "${BASE_DIR}/etc/cron" -mindepth 1 -type f -name 'sudo-*.sh' -exec echo {} \;); do
  printf "\033[1mAdding '%s' to root crontab ...\033[0m\n" "$f"
  sudo crontab "$f"
done

printf "\033[1m%s\033[0m:\n\n\t%s\n\n... \033[1m%s\033[0m\n" "Remember to generate your ssh keys" "https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent" "and update your ~/.gitconfig"
