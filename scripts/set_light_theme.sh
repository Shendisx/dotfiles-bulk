#!/bin/bash

SETTINGS_FILE="$HOME/.config/gtk-3.0/settings.ini"

# Check if settings.ini exists
if [ ! -f "$SETTINGS_FILE" ]; then
    touch "$SETTINGS_FILE"
fi

# Use sed to replace or add the line for light theme
if grep -q "gtk-application-prefer-dark-theme" "$SETTINGS_FILE"; then
    # If the line exists, replace it with light theme preference
    sed -i 's/^gtk-application-prefer-dark-theme = .*/gtk-application-prefer-dark-theme = false/' "$SETTINGS_FILE"
else
    # If it doesn't exist, add the light theme preference
    echo "gtk-application-prefer-dark-theme = false" >> "$SETTINGS_FILE"
fi
