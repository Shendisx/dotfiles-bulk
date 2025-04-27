#!/bin/bash
#xrandr --output HDMI-A-0 --mode 1920x1080 --rate 60 &
#sleep 3
#xrandr --output HDMI-A-0 --set TearFree on &
#feh --bg-fill $HOME/.config/qtile/Wallpaper/Skyscraper.png &
#picom --daemon --config $HOME/.config/qtile/scripts/picom.conf &
#wlr-randr --output HDMI-A-1 --mode 1920x1080@60
/usr/bin/lxqt-policykit-agent &
/usr/bin/wired &
/usr/bin/easyeffects --gapplication-service &
/usr/bin/copyq &
/usr/bin/corectrl &
/usr/bin/adaptivemmd &
xset r rate 220 60 &
eval $(gnome-keyring-daemon --start) &
#nm-applet &

