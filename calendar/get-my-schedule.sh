#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Get my schedule
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📅
# @raycast.needsConfirmation false
# @raycast.argument1 { "type": "text", "placeholder": "Date", "optional": true }

# Documentation:
# @raycast.description icalBuddy schedule of the day with formatted output
# @raycast.author egposadas
# @raycast.authorURL https://raycast.com/batcave/scripts

# Determine the date range for icalBuddy
if [[ -n "$1" ]]; then
  date="$1"
  raw_schedule=$(icalBuddy -nc -ps "|: |" -iep "datetime,title" -po "datetime,title" -tf "%H:%M" -ea -b "- " eventsFrom:"$date" to:"$date")
else
  raw_schedule=$(icalBuddy -nc -ps "|: |" -iep "datetime,title" -po "datetime,title" -tf "%H:%M" -ea -b "- " eventsToday)
fi

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
    # Remove everything before 'at ' including 'at '
    event_details=$(echo "$line" | sed 's/^.*at //')

    # Make the event title bold
    formatted_schedule+="- **$event_details**\n"
  fi
done <<< "$raw_schedule"

# Copy the formatted schedule to clipboard
echo -e "$formatted_schedule" | pbcopy

# Display success message
if [[ -n "$1" ]]; then
  echo "✅ Schedule for $1 copied to clipboard!"
else
  echo "✅ Today's schedule copied to clipboard!"
fi
