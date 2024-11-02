# get current git branch
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export -f parse_git_branch

parse_hostname() {
  local arg=${1:-1} replace=${2:-.}
  local count=$(hostname | grep '\.' | wc -l | xargs echo)
  [ $count -gt 1 ] || arg=1
  hostname | sed 's/\.lan$//' | cut -d. -f1-$arg | sed "s/\./$replace/g"
}
export -f parse_hostname

# Use 'parse_hostname' instead of '\h' for advacned customization
_PS1="\[\033[01;34m\]\u\[\033[0m\]@\[\033[01;32m\]\$(parse_hostname 10 '-')\[\033[00m\]:\[\033[01;34m\]\w\[\033[0;32m\]\$(parse_git_branch)\[\033[00m\]\$ "
export PS1=$_PS1
