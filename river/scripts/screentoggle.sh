#!/bin/sh

# Check the current state of the display
read lcd < /tmp/lcd

if [ "$lcd" -eq "0" ]; then
    riverctl output * dpms on  # Turn on the display
    echo 1 > /tmp/lcd           # Update state
else
    riverctl output * dpms off  # Turn off the display
    echo 0 > /tmp/lcd           # Update state
fi