for f in $(find /Users/Shared/etc/profile.d -mindepth 1 -maxdepth 1 -type f ! -name '.DS_Store' | sort); do
  . "$f"
done
