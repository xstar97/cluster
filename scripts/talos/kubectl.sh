#!/bin/bash

# Set the base path for the cluster
BASE_PATH="$PWD"

# Source the utility file
source $BASE_PATH/scripts/utils.sh

# Check if the following are installed
check_command "kubectl"

# Check if namespace argument is provided; if not, set to -A to list all namespaces
NAMESPACE=${1:+"-n $1"}
NAMESPACE=${NAMESPACE:--A}

# Set chart name filter if provided
CHART_NAME=${2:+"| grep $2"}

# Execute command
eval "kubectl get pods,svc,ingress $NAMESPACE ${CHART_NAME:-""}"
