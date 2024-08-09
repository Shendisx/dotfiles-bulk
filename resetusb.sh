#!/bin/bash

# Script to restart all USB host controllers

function restart_usb() {
  for hc in /sys/bus/pci/drivers/[uoex]hci_hcd/*:*; do
    if [ -d "$hc" ]; then
      hc_name="${hc##*/}"
      hc_dir="${hc%/*}"

      echo "Unbinding USB host controller: $hc_name"
      echo "$hc_name" > "$hc_dir/unbind"

      # Add a short delay for proper disconnection
      sleep 0.5

      echo "Rebinding USB host controller: $hc_name"
      echo "$hc_name" > "$hc_dir/bind"
    else
      echo "Error: USB host controller directory not found: $hc"
    fi
  done
}

restart_usb