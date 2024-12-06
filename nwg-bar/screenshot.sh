#!/usr/bin/env bash

MODE=$1

if [ -z "$MODE" ]; then
  MODE=output
fi

if [ "$XDG_CURRENT_DESKTOP" = "sway" ]; then
  sleep 0.2
  grimshot --notify save $MODE - | swappy -f -
fi

if [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ]; then
  hyprshot -r -m $MODE | swappy -f -
fi
