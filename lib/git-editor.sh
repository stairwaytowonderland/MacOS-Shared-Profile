#!/bin/bash

# TODO: this file could possibly be deleted. It's not currently being used or referenced. Need to see if there are errors with the updated config.

cmd="nano"
if [ -x "$(command -v bbedit)" ]; then
    cmd="bbedit --wait $@"
else
    cmd="nano $@"
fi
eval "$cmd"
