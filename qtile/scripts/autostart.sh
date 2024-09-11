#!/bin/bash
xrandr --output HDMI-A-0 --mode 1920x1080 --rate 60 &
#sleep 3
xrandr --output HDMI-A-0 --set TearFree on &
#feh --bg-fill $HOME/.config/qtile/Wallpaper/Skyscraper.png &
#picom --daemon --config $HOME/.config/qtile/scripts/picom.conf & 
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
/usr/bin/wired &
/usr/bin/jamesdsp -s -t &
xset r rate 220 60 &
eval $(gnome-keyring-daemon --start) &
#nm-applet &

