# Description: Updates flux manually
# Example: flux_updater
function flux_updater
    check_command flux
    echo "Reconciling Flux Git source..."
    if flux reconcile source git cluster cluster --verbose
        echo "Reconciled successfully."
    else
        echo "Failed to reconcile. Please check the Flux logs for more details."
        exit 1
    end
end
