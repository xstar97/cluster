#!/bin/bash

# Source the utility file
source /workspaces/cluster/scripts/utils.sh

# Check if the following are installed
check_command "kubectl"

# Check if -t flag is passed for test mode
test_mode=false
if [[ "$1" == "-t" ]]; then
  test_mode=true
fi

# Iterate over each line of pods with errors
while read -r line; do
  # Extract namespace and pod name
  namespace=$(echo "$line" | awk '{print $1}')
  pod_name=$(echo "$line" | awk '{print $2}')
  
  # Display pod information and prompt for deletion
  echo "Pod in error state:"
  echo "Namespace: $namespace, Pod: $pod_name"
  
  if $test_mode; then
    # Echo deletion command in test mode
    echo "Test Mode: kubectl delete pod $pod_name -n $namespace"
  else
    # Perform actual deletion
    kubectl delete pod "$pod_name" -n "$namespace"
    echo "Deleted pod $pod_name in namespace $namespace."
  fi
done < <(kubectl get pods -A | grep -E "Error|UnexpectedAdmissionError|CrashLoopBackOff|ContainerStatusUnknown|Init:0/1|Completed|OOMKilled")
