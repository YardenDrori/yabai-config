#!/usr/bin/env bash

# Focus a specific display
# Usage: focus_display.sh <display_number>

DISPLAY_NUM=$1

# Focus the display (this moves the mouse cursor to it)
yabai -m display --focus "$DISPLAY_NUM" 2>/dev/null || true
