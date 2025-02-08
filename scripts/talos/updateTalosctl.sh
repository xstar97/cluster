#!/bin/bash

# Define the path for talconfig
yaml_file="/workspaces/cluster/clusters/main/talos/talconfig.yaml"

# Extract the Talos version from talconfig
talos_version=$(grep '^talosVersion:' "$yaml_file" | awk '{print $2}' | tr -d '"' | tr -d '[:space:]')

if [[ -z "$talos_version" ]]; then
    echo "Error: Unable to extract Talos version from $yaml_file"
    exit 1
fi

echo "Talos version from talconfig: $talos_version"

# Ensure talosctl is available
if ! command -v talosctl &> /dev/null; then
    echo "Error: talosctl command not found. Installing talosctl..."
else
    # Get the installed talosctl version
    installed_version=$(talosctl version --short --client | awk '/Client/ {print $2}' | tr -d '"' | tr -d '[:space:]')

    if [[ -z "$installed_version" ]]; then
        echo "Error: Unable to determine installed talosctl version"
        exit 1
    fi

    echo "Installed talosctl version: $installed_version"

    # Compare versions
    if [[ "$talos_version" == "$installed_version" ]]; then
        echo "talosctl is up-to-date. No update needed."
        exit 0
    fi

    echo "Updating talosctl to version $talos_version..."
fi

download_url="https://github.com/siderolabs/talos/releases/download/$talos_version/talosctl-linux-amd64"

curl -LO "$download_url"
if [[ $? -ne 0 ]]; then
    echo "Error downloading talosctl from $download_url"
    exit 1
fi

chmod +x "talosctl-linux-amd64"
sudo mv "talosctl-linux-amd64" /usr/local/bin/talosctl

echo "talosctl updated to version $talos_version"
