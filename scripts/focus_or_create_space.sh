#!/usr/bin/env bash

# Focus or create a space dynamically using per-display virtual numbering
# Usage: focus_or_create_space.sh <space_number>
# Spaces 1-4 are static per-display, 5-9 are dynamic per-display

SPACE_NUM=$1

# Get display where mouse cursor is (display with focus)
CURRENT_DISPLAY=$(yabai -m query --displays --display | jq '.index')

# Label names for static workspaces
STATIC_LABELS=("one" "two" "three" "four")

if [ "$SPACE_NUM" -le 4 ]; then
    # Static spaces 1-4: find on current display by label
    LABEL_NAME="${STATIC_LABELS[$((SPACE_NUM-1))]}"
    LABEL="d${CURRENT_DISPLAY}-${LABEL_NAME}"

    EXISTING_SPACE=$(yabai -m query --spaces | jq -r ".[] | select(.display == $CURRENT_DISPLAY and .label == \"$LABEL\") | .index")

    if [ -n "$EXISTING_SPACE" ]; then
        yabai -m space --focus "$EXISTING_SPACE"
    else
        # Fallback: focus nth space on current display
        NTH_SPACE=$(yabai -m query --spaces | jq -r ".[] | select(.display == $CURRENT_DISPLAY) | .index" | sed -n "${SPACE_NUM}p")
        if [ -n "$NTH_SPACE" ]; then
            yabai -m space --focus "$NTH_SPACE"
        fi
    fi
else
    # Dynamic spaces 5-9: find by per-display label or create
    LABEL="d${CURRENT_DISPLAY}-ws${SPACE_NUM}"

    EXISTING_SPACE=$(yabai -m query --spaces | jq -r ".[] | select(.display == $CURRENT_DISPLAY and .label == \"$LABEL\") | .index")

    if [ -n "$EXISTING_SPACE" ]; then
        # Space with this label exists on current display, focus it
        yabai -m space --focus "$EXISTING_SPACE"
    else
        # Create new space and label it
        yabai -m space --create
        NEW_SPACE=$(yabai -m query --spaces | jq "map(select(.[\"is-native-fullscreen\"] == false and .display == $CURRENT_DISPLAY)) | sort_by(.index) | last | .index")
        yabai -m space "$NEW_SPACE" --label "$LABEL"
        yabai -m space --focus "$NEW_SPACE"
        # Refresh YabaiIndicator after creating space
        echo "refresh" | nc -U /tmp/yabai-indicator.socket 2>/dev/null || true
    fi
fi
