#!/bin/bash

# Source the utility file
source /workspaces/cluster/scripts/utils.sh

# Check if the following are installed
check_command "flux"

# Reconcile the Flux Git source
echo "Reconciling Flux Git source..."
if flux reconcile source git cluster cluster; then
    echo "Reconciled successfully."
else
    echo "Failed to reconcile. Please check the Flux logs for more details."
    exit 1
fi
