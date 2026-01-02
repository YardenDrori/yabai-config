#!/usr/bin/env bash

# Initialize per-display workspace labels
# Ensures spaces 1-4 on each display are properly labeled

# Get all displays
DISPLAY_COUNT=$(yabai -m query --displays | jq 'length')

# Label names for static workspaces
LABELS=("one" "two" "three" "four")

# For each display, label the first 4 spaces
for ((display=1; display<=DISPLAY_COUNT; display++)); do
    # Get spaces on this display
    DISPLAY_SPACES=$(yabai -m query --spaces | jq -r ".[] | select(.display == $display) | .index" | head -4)

    space_num=0
    for space_index in $DISPLAY_SPACES; do
        if [ $space_num -lt 4 ]; then
            label="d${display}-${LABELS[$space_num]}"
            # Only label if not already labeled correctly
            current_label=$(yabai -m query --spaces | jq -r ".[] | select(.index == $space_index) | .label")
            if [ "$current_label" != "$label" ]; then
                yabai -m space "$space_index" --label "$label" 2>/dev/null || true
            fi
            space_num=$((space_num + 1))
        fi
    done
done

# Refresh YabaiIndicator
echo "refresh" | nc -U /tmp/yabai-indicator.socket 2>/dev/null || true
