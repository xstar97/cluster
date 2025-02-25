# Description: Rebuilds cache for flux
# Example: flux_cleanup
function flux_cleanup
    check_command "kubectl"
    check_command "flux"
    # Fetch the name of the kustomize-controller pod
    echo "Looking for the kustomize-controller pod in the 'flux-system' namespace..."
    set POD_NAME (kubectl get pods -n flux-system -l app=kustomize-controller -o jsonpath='{.items[0].metadata.name}')

    if test -z "$POD_NAME"
        echo "Error: kustomize-controller pod not found. Please ensure Flux is installed and running in the 'flux-system' namespace."
        exit 1
    end

    echo "Found kustomize-controller pod: $POD_NAME"

    # Execute cleanup inside the pod
    echo "Cleaning up all files and directories in /tmp inside the pod..."
    kubectl exec -n flux-system -it "$POD_NAME" -- sh -c '
      if [ -n "$(ls -A /tmp/kustomization-* 2>/dev/null)" ]; then
        echo "Deleting directories first..."
        for dir in /tmp/kustomization-*; do
          if [ -d "$dir" ]; then
            echo "Removing directory: $dir"
            rm -rf "$dir"
          fi
        done

        echo "Deleting remaining files..."
        for file in /tmp/kustomization-*/*; do
          if [ -f "$file" ]; then
            echo "Removing file: $file"
            rm -f "$file"
          fi
        done
      else
        echo "/tmp is already empty."
      fi
    '

    if test $status -ne 0
        echo "Error: Failed to remove files and directories in /tmp. Please check the pod's state and permissions."
        exit 1
    end

    echo "Successfully removed all files and directories from /tmp inside the pod."

    # Reconcile the kustomization to rebuild the cache
    echo "Reconciling the 'flux-entry' kustomization in the 'flux-system' namespace to rebuild cache..."
    if not flux reconcile kustomization flux-entry --namespace flux-system --timeout 20m0s --verbose
        echo "Error: Failed to reconcile 'flux-entry'. Please verify the kustomization configuration and try again."
        exit 1
    end

    echo "Successfully reconciled 'flux-entry'. Cache should now be rebuilt."

    # Final success message
    echo "Cleanup script completed successfully. Everything is up-to-date and ready to go!"
end
