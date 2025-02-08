#!/bin/bash

# Define the path for talconfig
yaml_file="/workspaces/cluster/clusters/main/talos/talconfig.yaml"

# Extract the Kubernetes version from talconfig
kubernetes_version=$(grep '^kubernetesVersion:' "$yaml_file" | awk '{print $2}' | tr -d '"' | tr -d '[:space:]')

if [[ -z "$kubernetes_version" ]]; then
    echo "Error: Unable to extract Kubernetes version from $yaml_file"
    exit 1
fi

echo "Kubernetes version from talconfig: $kubernetes_version"

# Ensure kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl command not found. Installing kubectl..."
else
    # Get the installed kubectl version
    installed_version=$(kubectl version --client --client | awk -F ": " '/Client Version/ {print $2}' | tr -d '"' | tr -d '[:space:]')

    if [[ -z "$installed_version" ]]; then
        echo "Error: Unable to determine installed kubectl version"
        exit 1
    fi

    echo "Installed kubectl version: $installed_version"

    # Compare versions
    if [[ "$kubernetes_version" == "$installed_version" ]]; then
        echo "kubectl is up-to-date. No update needed."
        exit 0
    fi

    echo "Updating kubectl to version $kubernetes_version..."
fi

download_url="https://dl.k8s.io/release/$kubernetes_version/bin/linux/amd64/kubectl"

curl -LO "$download_url"
if [[ $? -ne 0 ]]; then
    echo "Error downloading kubectl from $download_url"
    exit 1
fi

chmod +x "kubectl"
sudo mv "kubectl" /usr/local/bin/kubectl

echo "kubectl updated to version $kubernetes_version"
