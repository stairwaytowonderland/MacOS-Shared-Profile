# get current git branch
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export -f parse_git_branch

parse_hostname() {
  local arg=${1:-1} replace=${2:-.}
  local count=$(hostname | grep -o '\.' | wc -l | xargs echo)
  [ $count -gt 1 ] || arg=1
  hostname | sed -E 's/\.lan|\.local$//' | cut -d. -f1-$arg | sed "s/\./$replace/g"
}
export -f parse_hostname

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
  xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes
if is "${FORCE_COLOR_PROMPT_WINDOWS:-$FALSE}" ; then
  ! is_windows || force_color_prompt=yes
fi

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
  else
    color_prompt=
  fi
fi

# Example of using debian_chroot in PS1
# if [ "$color_prompt" = yes ]; then
#     PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
# else
#     PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
# fi

# Use 'parse_hostname' instead of '\h' for advacned customization
if [ "$color_prompt" = "yes" ]; then
  _PS1="\[\033[01;34m\]\u\[\033[0m\]@\[\033[01;32m\]\$(parse_hostname 10 '-')\[\033[00m\]:\[\033[01;34m\]\w\[\033[0;32m\]\$(parse_git_branch)\[\033[00m\]\$ "
else
  _PS1="\u@\$(parse_hostname 10 '-'):\w\$(parse_git_branch)\$ "
fi
unset color_prompt force_color_prompt
export PS1=$_PS1
