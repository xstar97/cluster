#!/bin/bash

# Check if at least one argument (command) is provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 [interval] <command...>"
    exit 1
fi

# Default interval is 5 seconds
INTERVAL=5

# If the first argument is a number, use it as the interval
if [[ "$1" =~ ^[0-9]+$ ]]; then
    INTERVAL=$1
    shift  # Shift to remove interval argument, leaving only the command
fi

# Run watch with the determined interval and command
watch -n "$INTERVAL" "$@"
