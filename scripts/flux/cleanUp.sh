#!/bin/bash

# Function to check if a command is available
check_command() {
  if ! command -v "$1" &>/dev/null; then
    echo "Error: $1 is not installed. Please install it before running this script."
    exit 1
  fi
}

# Check if flux, yq, and kubectl are installed
check_command "flux"
check_command "yq"
check_command "jq"
check_command "kubectl"

# Get the name of the kustomize-controller pod
POD_NAME=$(kubectl get pods -n flux-system -l app=kustomize-controller -o jsonpath='{.items[0].metadata.name}')

if [ -z "$POD_NAME" ]; then
  echo "Error: kustomize-controller pod not found."
  exit 1
fi

echo "Found kustomize-controller pod: $POD_NAME"

# Execute the cleanup command inside the kustomize-controller pod
kubectl exec -n flux-system -it "$POD_NAME" -- sh -c "rm -rf /tmp/kustomization-*"
if [ $? -ne 0 ]; then
  echo "Error: Failed to remove cached kustomization files."
  exit 1
fi

echo "Successfully removed cached kustomization files."

# Reconcile the kustomization to rebuild cache
flux reconcile kustomization flux-entry --namespace flux-system
if [ $? -ne 0 ]; then
  echo "Error: Failed to reconcile flux-entry."
  exit 1
fi

echo "Reconciled flux-entry successfully."
