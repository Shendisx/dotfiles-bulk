#!/bin/bash

# Set the CPU governor to 'ondemand'
echo "Setting CPU governor to 'ondemand'..."
echo ondemand | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Set the up_threshold to 35
echo "Setting up_threshold to 35..."
echo 35 | sudo tee /sys/devices/system/cpu/cpufreq/ondemand/up_threshold

echo "Governor set to 'ondemand' with up_threshold of 35."
