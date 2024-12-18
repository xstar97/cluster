#!/bin/bash

# Check if namespace argument is provided; if not, set to -A to list all namespaces
NAMESPACE=${1:+"-n $1"}
NAMESPACE=${NAMESPACE:--A}

# Set chart name filter if provided
CHART_NAME=${2:+"| grep $2"}

# Execute command
eval "kubectl get pods,svc,ingress $NAMESPACE ${CHART_NAME:-""}"
