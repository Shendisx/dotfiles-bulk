#!/bin/bash
xrandr --output HDMI-A-0 --mode 1920x1080 --rate 60 &
#sleep 3
xrandr --output HDMI-A-0 --set TearFree on &
#feh --bg-fill $HOME/.config/qtile/Wallpaper/Skyscraper.png &
#picom --daemon --config $HOME/.config/qtile/scripts/picom.conf & 
/usr/bin/lxqt-policykit-agent &
/usr/bin/wired &
/usr/bin/jamesdsp -s -t &
/usr/bin/adaptivemmd
xset r rate 220 60 &
eval $(gnome-keyring-daemon --start) &
#nm-applet &

