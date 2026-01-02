#!/usr/bin/env bash

# Initialize per-display workspace labels
# Ensures the first space on each display is properly labeled as "one"

# Get all displays
DISPLAY_COUNT=$(yabai -m query --displays | jq 'length')

# For each display, label only the first space
for ((display=1; display<=DISPLAY_COUNT; display++)); do
    # Get the first space on this display
    FIRST_SPACE=$(yabai -m query --spaces | jq -r ".[] | select(.display == $display) | .index" | head -1)

    if [ -n "$FIRST_SPACE" ]; then
        label="d${display}-one"
        # Only label if not already labeled correctly
        current_label=$(yabai -m query --spaces | jq -r ".[] | select(.index == $FIRST_SPACE) | .label")
        if [ "$current_label" != "$label" ]; then
            yabai -m space "$FIRST_SPACE" --label "$label" 2>/dev/null || true
        fi
    fi
done

# Refresh YabaiIndicator
echo "refresh" | nc -U /tmp/yabai-indicator.socket 2>/dev/null || true
