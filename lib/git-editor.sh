#!/bin/bash

cmd="nano"
if [ -x "$(command -v bbedit)" ]; then
    cmd="bbedit --wait $@"
else
    cmd="nano $@"
fi
eval "$cmd"
