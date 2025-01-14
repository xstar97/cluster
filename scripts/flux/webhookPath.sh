#!/bin/bash

# Function to check if a command is available
check_command() {
  if ! command -v "$1" &>/dev/null; then
    echo "Error: $1 is not installed. Please install it before running this script."
    exit 1
  fi
}

# Check if flux, yq, jq, and kubectl are installed
check_command "flux"
check_command "yq"
check_command "jq"
check_command "kubectl"

# Namespace and receiver name
NAMESPACE="flux-system"
RECEIVER_NAME="github-receiver"

# Retrieve the webhook path
WEBHOOK_PATH=$(kubectl -n "$NAMESPACE" get receiver "$RECEIVER_NAME" -o jsonpath='{.status.webhookPath}')

# Base URL (replace this with the actual base URL of your ingress for github receiver)
BASE_URL="https://example.com"  # Change "example.com" as needed

# Output the full webhook URL
if [[ -n "$WEBHOOK_PATH" ]]; then
  echo "The webhook URL is: $BASE_URL$WEBHOOK_PATH"
else
  echo "Error: Could not retrieve the webhook path for receiver '$RECEIVER_NAME' in namespace '$NAMESPACE'."
  exit 1
fi
