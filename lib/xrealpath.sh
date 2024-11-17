#!/bin/bash

__xrealpath() (
    local path=$1 file=''
    if [ ! -d "$path" ]; then
      file=/$(basename -- "$path")
      path=$(dirname -- "$path")
    fi
    path=$(cd -- "$path" && pwd)$file || return $?
    printf %s\\n "/${path#"${path%%[!/]*}"}"
)
command -v realpath >/dev/null && alias xrealpath='__xrealpath' || alias realpath='__xrealpath'
