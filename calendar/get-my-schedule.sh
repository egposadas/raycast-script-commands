#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Get my schedule
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📅
# @raycast.needsConfirmation false

# Documentation:
# @raycast.description icalBuddy schedule of the day with formatted output
# @raycast.author egposadas
# @raycast.authorURL https://raycast.com/batcave/scripts

# Get the raw schedule from icalBuddy
raw_schedule=$(icalBuddy -nc -ps "|: |" -iep "datetime,title" -po "datetime,title" -df "%H%M" -ea -b "- " eventsToday)

# For testing purposes, uncomment this line and comment out the line above
# raw_schedule=$(cat test_data.md)

# Check if the schedule is empty
if [[ -z "$raw_schedule" ]]; then
  echo "No events scheduled for today!"
  exit 0
fi

# Format the schedule with bold titles only
formatted_schedule=""
while IFS= read -r line; do
  if [[ -n "$line" ]]; then
    # Extract the event details, removing any leading "- " if present
    event_details="${line#- }"
    
    # Make the event title bold
    formatted_schedule+="- **$event_details**\n"
  fi
done <<< "$raw_schedule"

# Copy the formatted schedule to clipboard
echo -e "$formatted_schedule" | pbcopy

# Display success message
echo "✅ Today's schedule copied to clipboard!"
