#!/usr/bin/env sh

# Make window sticky (appears on all workspaces)
yabai -m window $YABAI_WINDOW_ID --toggle sticky

# Get display dimensions
DISPLAY_WIDTH=$(yabai -m query --displays --display | jq -r '.frame.w')
DISPLAY_HEIGHT=$(yabai -m query --displays --display | jq -r '.frame.h')

# Move and resize the window to fullscreen
yabai -m window $YABAI_WINDOW_ID --move abs:0:0
yabai -m window $YABAI_WINDOW_ID --resize abs:${DISPLAY_WIDTH}:${DISPLAY_HEIGHT}

# Focus the window
yabai -m window --focus $YABAI_WINDOW_ID
