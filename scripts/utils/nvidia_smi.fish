# utils/nvidia_smi.fish

# Function to run nvidia-smi in a kubectl pod
function nvidia_smi
    check_command "kubectl"
    # Run kubectl with nvidia-smi inside the pod if both commands are available
    kubectl run nvidia-test --restart=Never -ti --rm --image nvcr.io/nvidia/cuda:12.1.0-base-ubuntu22.04 --overrides='{"spec": {"runtimeClassName": "nvidia"}}' -- nvidia-smi
end
