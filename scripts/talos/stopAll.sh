#!/bin/bash

# Source the utility file
source /workspaces/cluster/scripts/utils.sh

# Check if the following are installed
check_command "kubectl"

# Check if chart name is provided
if [[ -z "$1" ]]; then
  echo "Usage: $0 <chart-name> -n <namespace>"
  exit 1
fi

CHART_NAME="$1"
NAMESPACE="$1"

# Parse namespace flag if provided
while [[ $# -gt 0 ]]; do
  case "$1" in
    -n)
      NAMESPACE="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

echo "...checking state"

# Get current stopAll value
CURRENT_STATE=$(kubectl get helmrelease "$CHART_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.values.global.stopAll}' 2>/dev/null)

if [[ -z "$CURRENT_STATE" ]]; then
  echo "Error: Could not retrieve stopAll value for $CHART_NAME in namespace $NAMESPACE"
  exit 1
fi

echo "stopAll is $CURRENT_STATE"

# Toggle stopAll value
NEW_STATE="true"
if [[ "$CURRENT_STATE" == "true" ]]; then
  NEW_STATE="false"
fi

echo "setting stopAll to $NEW_STATE"

# Apply the patch
kubectl patch helmrelease "$CHART_NAME" -n "$NAMESPACE" --type='merge' -p \
  "{\"spec\":{\"values\":{\"global\":{\"stopAll\":$NEW_STATE}}}}"

echo "stopAll is now $NEW_STATE"
