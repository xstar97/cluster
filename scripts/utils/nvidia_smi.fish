# Description: Creates a temp container to run nvidia-smi on the cluster
# Example: nvidia_smi
function nvidia_smi
    check_command "kubectl"
    # Run kubectl with nvidia-smi inside the pod if both commands are available
    kubectl run nvidia-test --restart=Never -ti --rm --image nvcr.io/nvidia/cuda:12.1.0-base-ubuntu22.04 --overrides='{"spec": {"runtimeClassName": "nvidia"}}' -- nvidia-smi
end
