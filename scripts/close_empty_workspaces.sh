#!/bin/bash

LOG_FILE="/Users/yardendrori/skhd.log"
echo "Script started at $(date)" > $LOG_FILE

# Iterate through spaces 5 to 9
for i in {5..9}; do
  # Query yabai for the current space and check if it's empty
  is_empty=$(/opt/homebrew/bin/yabai -m query --spaces | /usr/bin/jq -r --argjson i "$i" '.[] | select(.index == $i and .windows == []) | .index')

  if [ -n "$is_empty" ]; then
    echo "Space $i is empty. Destroying..." >> $LOG_FILE
    /opt/homebrew/bin/yabai -m space --destroy "$i"
  else
    echo "Space $i is not empty or does not exist." >> $LOG_FILE
  fi
done

echo "Script finished at $(date)" >> $LOG_FILE
