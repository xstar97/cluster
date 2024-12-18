#!/bin/bash

# Function to check if a command is installed
check_command() {
  if ! command -v "$1" &> /dev/null; then
    echo "Error: $1 is not installed. Please install it before running this script."
    exit 1
  fi
}

# Check if flux is installed
check_command "flux"

# Reconcile the Flux Git source
echo "Reconciling Flux Git source..."
if flux reconcile source git cluster cluster; then
    echo "Reconciled successfully."
else
    echo "Failed to reconcile. Please check the Flux logs for more details."
    exit 1
fi
