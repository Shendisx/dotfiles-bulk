#!/bin/bash

# Command to turn off the screen
/bin/dbus-send --session --print-reply --dest=org.kde.kglobalaccel /component/org_kde_powerdevil org.kde.kglobalaccel.Component.invokeShortcut string:'Turn Off Screen' && sudo cpupower frequency-set -g powersave
