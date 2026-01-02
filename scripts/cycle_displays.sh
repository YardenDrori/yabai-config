#!/usr/bin/env bash

# Cycle to the next display and move cursor to it
# Gets current display and focuses the next one (wraps around)

CURRENT_DISPLAY=$(yabai -m query --displays --display | jq '.index')
DISPLAY_COUNT=$(yabai -m query --displays | jq 'length')

NEXT_DISPLAY=$((CURRENT_DISPLAY % DISPLAY_COUNT + 1))

# Get display frame and move cursor to center
DISPLAY_INFO=$(yabai -m query --displays --display "$NEXT_DISPLAY")
DISPLAY_X=$(echo "$DISPLAY_INFO" | jq '.frame.x')
DISPLAY_Y=$(echo "$DISPLAY_INFO" | jq '.frame.y')
DISPLAY_W=$(echo "$DISPLAY_INFO" | jq '.frame.w')
DISPLAY_H=$(echo "$DISPLAY_INFO" | jq '.frame.h')

# Calculate a point just below the menu bar to click
CENTER_X=$(awk "BEGIN {print int($DISPLAY_X + $DISPLAY_W / 2)}")
CLICK_Y=$(awk "BEGIN {print int($DISPLAY_Y + 50)}")

# Move cursor and click to activate display using Swift
swift - <<EOF
import Foundation
import CoreGraphics

let point = CGPoint(x: $CENTER_X, y: $CLICK_Y)

// Move cursor
CGWarpMouseCursorPosition(point)
CGAssociateMouseAndMouseCursorPosition(1)

// Longer delay to ensure cursor has moved
usleep(200000)

// Create and post click events
if let source = CGEventSource(stateID: .hidSystemState) {
    if let mouseDown = CGEvent(mouseEventSource: source, mouseType: .leftMouseDown, mouseCursorPosition: point, mouseButton: .left),
       let mouseUp = CGEvent(mouseEventSource: source, mouseType: .leftMouseUp, mouseCursorPosition: point, mouseButton: .left) {
        mouseDown.post(tap: .cghidEventTap)
        usleep(10000)
        mouseUp.post(tap: .cghidEventTap)
    }
}
EOF
