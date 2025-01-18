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
INGRESS_NAME="webhook-receiver"

# Retrieve the ingress URL (address or host)
BASE_URL=$(kubectl -n "$NAMESPACE" get ingress "$INGRESS_NAME" -o jsonpath='{.spec.rules[0].host}')

if [[ -z "$BASE_URL" ]]; then
  # Fallback to address if host is not defined
  BASE_URL=$(kubectl -n "$NAMESPACE" get ingress "$INGRESS_NAME" -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
fi

if [[ -z "$BASE_URL" ]]; then
  echo "Error: Could not retrieve the ingress URL for '$INGRESS_NAME' in namespace '$NAMESPACE'."
  exit 1
fi

# Retrieve the webhook path
WEBHOOK_PATH=$(kubectl -n "$NAMESPACE" get receiver "$RECEIVER_NAME" -o jsonpath='{.status.webhookPath}')

# Output the full webhook URL
if [[ -n "$WEBHOOK_PATH" ]]; then
  echo "The webhook URL is: https://$BASE_URL$WEBHOOK_PATH"
else
  echo "Error: Could not retrieve the webhook path for receiver '$RECEIVER_NAME' in namespace '$NAMESPACE'."
  exit 1
fi
