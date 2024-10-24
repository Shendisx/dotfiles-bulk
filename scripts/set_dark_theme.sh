#!/bin/bash

SETTINGS_FILE="$HOME/.config/gtk-3.0/settings.ini"

# Check if settings.ini exists
if [ ! -f "$SETTINGS_FILE" ]; then
    touch "$SETTINGS_FILE"
fi

# Use sed to replace or add the line
if grep -q "gtk-application-prefer-dark-theme" "$SETTINGS_FILE"; then
    # If the line exists, replace it
    sed -i 's/^gtk-application-prefer-dark-theme = .*/gtk-application-prefer-dark-theme = true/' "$SETTINGS_FILE"
else
    # If it doesn't exist, add it to the end of the file
    echo "gtk-application-prefer-dark-theme = true" >> "$SETTINGS_FILE"
fi
