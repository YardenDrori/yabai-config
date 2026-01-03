#!/usr/bin/env bash

# Clean up empty dynamic spaces (per-display ws2-ws10) and unlabeled spaces
# Spaces with labels matching "d*-ws*" pattern or unlabeled spaces beyond position 1 will be destroyed if empty
# Static space (d*-one) is never destroyed
# Workspaces with non-hidden, non-minimized windows are preserved (hidden and minimized windows are ignored)
# Unlabeled workspaces with windows are auto-labeled with the next available workspace number

# Get current space to avoid destroying it
CURRENT_SPACE=$(yabai -m query --spaces --space | jq '.index')

# Get list of actual window space indices (non-hidden, non-minimized windows)
WINDOW_SPACES=$(yabai -m query --windows | jq -r '[.[] | select(."is-hidden" == false and ."is-minimized" == false) | .space] | unique | .[]')

# First pass: Auto-label unlabeled workspaces with windows
for display in $(yabai -m query --displays | jq -r '.[].index'); do
    # Get existing workspace numbers on this display
    EXISTING_NUMBERS=$(yabai -m query --spaces | jq -r ".[] | select(.display == $display and .label != \"\") | .label" | grep -o "ws[0-9]\+" | sed 's/ws//' | sort -n)

    # Get unlabeled spaces on this display
    yabai -m query --spaces | jq -r "[.[] | select(.display == $display)] | map(.index) | sort | .[]" | while read -r SPACE_INDEX; do
        LABEL=$(yabai -m query --spaces | jq -r ".[] | select(.index == $SPACE_INDEX) | .label")
        POSITION=$(yabai -m query --spaces | jq "[.[] | select(.display == $display)] | map(.index) | sort | to_entries | .[] | select(.value == $SPACE_INDEX) | .key + 1")

        # If unlabeled and beyond position 1 and has windows
        if [ -z "$LABEL" ] && [ "$POSITION" -gt 1 ]; then
            if echo "$WINDOW_SPACES" | grep -q "^${SPACE_INDEX}$"; then
                # Find next available workspace number (2-10)
                for num in {2..10}; do
                    if ! echo "$EXISTING_NUMBERS" | grep -q "^${num}$"; then
                        # Found available number, label it
                        yabai -m space "$SPACE_INDEX" --label "d${display}-ws${num}" 2>/dev/null || true
                        break
                    fi
                done
            fi
        fi
    done
done

# Second pass: Clean up empty dynamic spaces
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
