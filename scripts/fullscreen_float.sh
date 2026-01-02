#!/usr/bin/env sh

# For floating windows that can't be managed (like Music)
# Get display dimensions
DISPLAY_WIDTH=$(yabai -m query --displays --display | jq -r '.frame.w')
DISPLAY_HEIGHT=$(yabai -m query --displays --display | jq -r '.frame.h')

# Try to move and resize the window to fullscreen
yabai -m window $YABAI_WINDOW_ID --move abs:0:0 2>/dev/null
yabai -m window $YABAI_WINDOW_ID --resize abs:${DISPLAY_WIDTH}:${DISPLAY_HEIGHT} 2>/dev/null

# Focus the window
yabai -m window --focus $YABAI_WINDOW_ID 2>/dev/null
