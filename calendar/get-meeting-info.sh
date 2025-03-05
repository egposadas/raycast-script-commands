#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Get Meeting Info
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 👥
# @raycast.argument1 { "type": "text", "placeholder": "Meeting Title" }
# @raycast.argument2 { "type": "text", "placeholder": "Date (YYYY-MM-DD)", "optional": true }

# Documentation:
# @raycast.description Get information about a calendar event based on the title
# @raycast.author egposadas
# @raycast.authorURL https://raycast.com/batcave/scripts

# Get the search term from the argument
search_term=$(echo "$1" | tr '[:upper:]' '[:lower:]')

# Check if the second argument is provided; if not, default to eventsToday
if [ -z "$2" ]; then
  events=$(icalBuddy -nc -na 10 -ps "|\n- |" -iep "title,attendees" -po "title,attendees" -b "- title: " -ea eventsToday)
else
  date="$2"
  events=$(icalBuddy -nc -na 10 -ps "|\n- |" -iep "title,attendees" -po "title,attendees" -b "- title: " -ea eventsFrom:"$date" to:"$date")
fi

# Process the output to find matching events
found=false
title=""
attendees=""

while IFS= read -r line; do
  if [[ "$line" == "- title: "* ]]; then
    # If we found a match in the previous iteration, print it and exit
    if [[ "$found" == true ]]; then
      # Extract just the attendees part without the prefix
      attendees_only="${attendees#- attendees: }"
      # Format the output with three bullets
      formatted_output="- _Attendees:_ $attendees_only\n- _Notes:_\n- _References:_"
      echo -e "$formatted_output" | pbcopy
      echo "✅ Meeting info for \"${title#- title: }\" on ${date:-today} copied to clipboard"
      exit 0
    fi
    
    # Reset for new event
    found=false
    title="$line"
    
    # Extract just the title part for comparison
    event_title=$(echo "${line#- title: }" | tr '[:upper:]' '[:lower:]')
    
    # Check if the search term is in the event title
    if [[ "$event_title" == *"$search_term"* ]]; then
      found=true
    fi
  elif [[ "$line" == "- attendees: "* && "$found" == true ]]; then
    attendees="$line"
  fi
done <<< "$events"

# Check if the last event was a match
if [[ "$found" == true ]]; then
  # Extract just the attendees part without the prefix
  attendees_only="${attendees#- attendees: }"
  # Format the output with three bullets
  formatted_output="- _Attendees:_ $attendees_only\n- _Notes:_\n- _References:_"
  echo -e "$formatted_output" | pbcopy
  echo "✅ Meeting info for \"${title#- title: }\" on ${date:-today} copied to clipboard"
  exit 0
fi

echo "❌ No matching event found for '$1' on ${date:-today}"
exit 1

