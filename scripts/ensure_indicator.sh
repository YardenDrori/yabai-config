#!/usr/bin/env bash

# Check if YabaiIndicator is running, start it if not
if ! pgrep -f "YabaiIndicator.app" > /dev/null; then
    open -a YabaiIndicator
fi
