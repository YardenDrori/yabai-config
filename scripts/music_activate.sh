#!/usr/bin/env sh

# When Music is activated (clicked/opened while already running)
# Find the Music window and make it sticky + fullscreen

MUSIC_WINDOW=$(yabai -m query --windows | jq -r '.[] | select(.app == "Music") | .id')

if [ -n "$MUSIC_WINDOW" ]; then
    # Check if already sticky
    IS_STICKY=$(yabai -m query --windows --window "$MUSIC_WINDOW" | jq -r '."is-sticky"')

    if [ "$IS_STICKY" != "true" ]; then
        # Make it sticky
        yabai -m window "$MUSIC_WINDOW" --toggle sticky

        # Get display dimensions
        DISPLAY_WIDTH=$(yabai -m query --displays --display | jq -r '.frame.w')
        DISPLAY_HEIGHT=$(yabai -m query --displays --display | jq -r '.frame.h')

        # Move and resize the window to fullscreen
        yabai -m window "$MUSIC_WINDOW" --move abs:0:0
        yabai -m window "$MUSIC_WINDOW" --resize abs:${DISPLAY_WIDTH}:${DISPLAY_HEIGHT}
    fi

    # Always focus the window when activated
    yabai -m window --focus "$MUSIC_WINDOW"
fi
