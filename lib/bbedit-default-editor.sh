#!/bin/sh

defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers \
  -array-add '{LSHandlerContentType=public.plain-text;LSHandlerRoleAll=com.barebones.bbedit;}'
