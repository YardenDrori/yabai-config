#!/usr/bin/env bash

# Clean up empty dynamic spaces (per-display ws2-ws10) and unlabeled spaces
# Spaces with labels matching "d*-ws*" pattern or unlabeled spaces beyond position 1 will be destroyed if empty
# Static space (d*-one) is never destroyed
# Hidden windows are ignored (only visible windows prevent cleanup)

# Get current space to avoid destroying it
CURRENT_SPACE=$(yabai -m query --spaces --space | jq '.index')

# Get list of actual window space indices (excluding hidden windows)
WINDOW_SPACES=$(yabai -m query --windows | jq -r '[.[] | select(."is-hidden" == false) | .space] | unique | .[]')

# Get all spaces on each display
for display in $(yabai -m query --displays | jq -r '.[].index'); do
    # Get space indices on this display, sorted in reverse order
    yabai -m query --spaces | jq -r "[.[] | select(.display == $display) | .index] | sort | reverse | .[]" | while read -r SPACE_INDEX; do
        if [ "$SPACE_INDEX" != "$CURRENT_SPACE" ]; then
            # Get label for this space
            LABEL=$(yabai -m query --spaces | jq -r ".[] | select(.index == $SPACE_INDEX) | .label")

            # Get position of this space on its display (1-based)
            POSITION=$(yabai -m query --spaces | jq "[.[] | select(.display == $display)] | map(.index) | sort | to_entries | .[] | select(.value == $SPACE_INDEX) | .key + 1")

            # Skip if this is the first space on this display (static)
            if [ "$POSITION" -eq 1 ]; then
                continue
            fi

            # Destroy if it's a dynamic workspace (d*-ws*) or unlabeled, and has no windows
            if [[ "$LABEL" =~ ^d[0-9]+-ws[0-9]+$ ]] || [ -z "$LABEL" ]; then
                if ! echo "$WINDOW_SPACES" | grep -q "^${SPACE_INDEX}$"; then
                    # No windows found, destroy it
                    yabai -m space "$SPACE_INDEX" --destroy
                fi
            fi
        fi
    done
done

# Refresh YabaiIndicator after cleanup
echo "refresh" | nc -U /tmp/yabai-indicator.socket 2>/dev/null || true
