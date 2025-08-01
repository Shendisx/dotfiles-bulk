#!/bin/bash

/usr/bin/lxqt-policykit-agent &
/usr/bin/copyq &
/usr/bin/dunst &
/usr/bin/easyeffects --gapplication-service &
xset r rate 220 60 &
xset s off &
xrandr --output HDMI-A-0 --set TearFree on &

