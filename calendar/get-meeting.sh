#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Get Meeting
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 👥
# @raycast.argument1 { "type": "text", "placeholder": "Meeting title" }
# @raycast.argument2 { "type": "text", "placeholder": "Date (Date, optional)", "optional": true }

# Documentation:
# @raycast.description Find meeting details by partial title match
# @raycast.author egposadas
# @raycast.authorURL https://raycast.com/batcave/scripts

# Get the search term from the argument
search_term=$(echo "$1" | tr '[:upper:]' '[:lower:]')

# Check if date parameter is provided
if [ -n "$2" ]; then
  # Use the specific date provided
  date_param="$2"
  events=$(icalBuddy -nc -ps "|: |" -iep "datetime,title" -po "datetime,title" -df "%H%M" -ea eventsFrom:$date_param to:$date_param)
else
  # Default to today if no date is specified
  events=$(icalBuddy -nc -ps "|: |" -iep "datetime,title" -po "datetime,title" -df "%H%M" -ea eventsToday)
fi

# Initialize variables
found=false
result=""

# Process each line of the events
while IFS= read -r line; do
  # Extract the time and title
  time_part=$(echo "$line" | sed -E 's/^- ([0-9]{4} - [0-9]{4}): .*/\1/')
  title_part=$(echo "$line" | sed -E 's/^- [0-9]{4} - [0-9]{4}: (.*)/\1/')
  
  # Convert title to lowercase for case-insensitive comparison
  title_lower=$(echo "$title_part" | tr '[:upper:]' '[:lower:]')
  
  # Check if the search term is in the title
  if [[ "$title_lower" == *"$search_term"* ]]; then
    found=true
    result="$time_part: $title_part"
    break
  fi
done <<< "$events"

# Output the result
if [ "$found" = true ]; then
  # Format for display in Raycast
  echo "**Meeting found:** $result"
  
  # Format for clipboard (just the raw result)
  echo -n "$result" | pbcopy
  echo "✅ \"$title_part\" details copied to clipboard"
else
  echo "❌ No meeting found matching \"$1\""
fi

