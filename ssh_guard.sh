#!/bin/bash
STATE_FILE="$HOME/.failed_rhosts.state"
OUTPUT_FILE="$HOME/failed_rhosts.log"
BLOCKED_IPS_FILE="$HOME/blocked_ips.list"

# If no state file, this is first run
if [[ ! -f "$STATE_FILE" ]]; then
    since="5 minutes ago"
else
    since=$(cat "$STATE_FILE")
fi

# Current time (will be saved as new state)
now=$(date --iso-8601=seconds)

# Collect failed ssh attempts with CLF timestamp
journalctl -u ssh --since "$since" --until "$now" \
  | awk -F'rhost=' -v now="$now" ' /authentication failure/ {
        split($2,a," ");
        ip=a[1];
        # CLF timestamp: [day/Mon/year:hour:minute:second +0000]
        cmd="date -d \"" now "\" \"+[%d/%b/%Y:%H:%M:%S %z]\"";
        cmd | getline ts;
        close(cmd);
        print ip, ts;
    }' >> "$OUTPUT_FILE"

# Save the last timestamp for next run
echo "$now" > "$STATE_FILE"

# --- Detect brute force ---
# Count failed attempts in last 5 minutes
recent_ips=$(tail -n 500 "$OUTPUT_FILE" | awk -v now="$now" '
    {
        ip=$1;
        attempts[ip]++;
    }
    END {
        for (i in attempts) {
            if (attempts[i] > 3) print i;
        }
    }')

for ip in $recent_ips; do
    # Check if already blocked
    if ! grep -q "$ip" "$BLOCKED_IPS_FILE" 2>/dev/null; then
        # Block with iptables
	echo $ip
        iptables -A INPUT -p tcp --dport 22 -s "$ip" -j DROP
        echo "$ip" >> "$BLOCKED_IPS_FILE"
        echo "$(date '+%d/%b/%Y:%H:%M:%S %z') BLOCKED $ip (more than 3 failed attempts)" >> "$OUTPUT_FILE"
    fi
done
