#!/bin/bash

# Source the utility file
source /workspaces/cluster/scripts/utils.sh

# Check if the following are installed
check_command "kubectl"

# Usage: ./describe_pods.sh <namespace> [-save]
namespace="$1"
save_flag="$2"
# Check if -save flag is provided and create directory for saving output if necessary
output_dir="output/${namespace}"

# Check if namespace argument is provided
if [ -z "$namespace" ]; then
    echo "Please specify a namespace."
    exit 1
fi

if [ "$save_flag" == "-save" ]; then
    mkdir -p "$output_dir"
    echo "Saving output to directory $output_dir"
fi

# Get a list of pods in the specified namespace
pods=$(kubectl get pods -n "$namespace" -o jsonpath='{.items[*].metadata.name}')

# Loop through each pod
for pod in $pods; do
    # Prepare to write to file if -save flag is set
    if [ "$save_flag" == "-save" ]; then
        pod_file="${output_dir}/${pod}.txt"
        echo "Writing to $pod_file"
        exec > "$pod_file"  # Redirect output to pod file
    else
        exec > >(tee /dev/stderr)  # Redirect output to console and stderr
    fi

    # Print pod information
    {
        echo "============================="
        echo "Pod: $pod"
        echo "============================="
        
        # Describe the pod
        echo "--- Pod Description ---"
        kubectl describe pod "$pod" -n "$namespace" || echo "Failed to describe pod $pod"

        # Get containers in the pod
        containers=$(kubectl get pod "$pod" -n "$namespace" -o jsonpath='{.spec.containers[*].name}')

        # Loop through each container and get logs
        for container in $containers; do
            echo "--- Logs for Container: $container ---"
            kubectl logs "$pod" -n "$namespace" -c "$container" || echo "Failed to get logs for container $container in pod $pod"
            echo "-------------------------"
        done
        
        echo "========================================"
    }
done
