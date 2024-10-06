# get current git branch
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export -f parse_git_branch

# find username@hostname:$
export PS1="\[\033[01;34m\]\u\[\033[0m\]@\[\033[01;32m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[0;32m\]\$(parse_git_branch)\[\033[00m\]\$ "
