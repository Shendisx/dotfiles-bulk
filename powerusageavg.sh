#!/bin/bash

# Initialize variables
total_power=0
count=0
duration=60 # Total duration to monitor in seconds
end_time=$((SECONDS + duration))

# Monitoring loop
while [ $SECONDS -lt $end_time ]; do
    # Clear the terminal for better readability
    clear  
    # Get the sensor value and extract power usage in W
    power_output=$(sensors | grep "power1")  # Replace with your specific sensor name
    if [[ $power_output =~ ([0-9]+\.[0-9]+) ]]; then
        power_value=${BASH_REMATCH[1]}  # Extract the numeric value
        total_power=$(echo "$total_power + $power_value" | bc)  # Sum up power values
        count=$((count + 1))  # Increment count
        
        echo "Current Power Usage: $power_value W"
    else
        echo "Sensor output not found or invalid."
    fi
    
    sleep 1  # Wait for 1 second before repeating
done

# Calculate average power usage
if [ $count -gt 0 ]; then
    average_power=$(echo "scale=2; $total_power / $count" | bc)
    echo "Average Power Usage over $duration seconds: $average_power W"
else
    echo "No valid readings were obtained."
fi
