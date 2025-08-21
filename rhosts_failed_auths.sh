#!/bin/bash
STATE_FILE="$HOME/.failed_rhosts.state"
OUTPUT_FILE="$HOME/failed_rhosts.log"

# If no state file, this is first run
if [[ ! -f "$STATE_FILE" ]]; then
    since="5 minutes ago"
else
    since=$(cat "$STATE_FILE")
fi

# Current time (will be saved as new state)
now=$(date --iso-8601=seconds)

# Get logs from "since" until "now"
journalctl -u ssh --since "$since" --until "$now" \
  | awk -F'rhost=' '/authentication failure/ {
        split($2,a," ");
        print a[1]
    }' >> "$OUTPUT_FILE"

# Save the last timestamp for next run
echo "$now" > "$STATE_FILE"

