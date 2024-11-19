#!/bin/bash

# Duration in seconds (5 minutes)
DURATION=300
# Start time
START_TIME=$(date +%s)

# Move the mouse smoothly in small increments until the duration is reached
while true; do
    # Check if the elapsed time has reached the duration
    ELAPSED_TIME=$(( $(date +%s) - START_TIME ))
    if [ $ELAPSED_TIME -ge $DURATION ]; then
        break
    fi

    # Move the mouse relative to its current position
    xdotool mousemove_relative 200 0 
    sleep 0.01  # Adjust the sleep duration for smoother movement
done
