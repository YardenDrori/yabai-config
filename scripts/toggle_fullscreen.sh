#!/usr/bin/env sh

# Get the current state of external_fullscreen
CURRENT_STATE=$(yabai -m config external_fullscreen)

if [ "$CURRENT_STATE" = "on" ]; then
  yabai -m config external_fullscreen off
else
  yabai -m config external_fullscreen on
fi
