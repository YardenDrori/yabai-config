#!/usr/bin/env sh

# Generic fullscreen script for any window
# Get display dimensions
DISPLAY_WIDTH=$(yabai -m query --displays --display | jq -r '.frame.w')
DISPLAY_HEIGHT=$(yabai -m query --displays --display | jq -r '.frame.h')

# Move and resize the window to fullscreen
yabai -m window $YABAI_WINDOW_ID --move abs:0:0
yabai -m window $YABAI_WINDOW_ID --resize abs:${DISPLAY_WIDTH}:${DISPLAY_HEIGHT}
