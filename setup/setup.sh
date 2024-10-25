# Symlinks

if [ -f "$0" ]; then
  SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
else
  SCRIPT_DIR="$(pwd)"
fi

PARENT_DIR="$(dirname $SCRIPT_DIR)"

ln -s "${PARENT_DIR}/lib/bbwait.sh" "${PARENT_DIR}/bin/bbwait"
ln -s "${PARENT_DIR}/lib/bbdiff.sh" "${PARENT_DIR}/bin/bbdiff"

ln -s "${PARENT_DIR}/etc/profile.d" ~/profile.d
ln -s "${PARENT_DIR}/bin" ~/bin
