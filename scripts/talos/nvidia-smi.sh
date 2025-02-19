#!/bin/bash

# Set the base path for the cluster
BASE_PATH="$PWD"

# Source the utility file
source $BASE_PATH/scripts/utils.sh

# Check if any the following commands are installed
check_command "kubectl"

echo testing nvidia-smi through the cluster...

kubectl run nvidia-test --restart=Never -ti --rm --image nvcr.io/nvidia/cuda:12.1.0-base-ubuntu22.04 --overrides='{"spec": {"runtimeClassName": "nvidia"}}' -- nvidia-smi
