#!/bin/bash

# Set the base path for the cluster
BASE_PATH="$PWD"

# Define the path for talconfig
yaml_file="$BASE_PATH/clusters/main/talos/talconfig.yaml"

# Generic function to update a CLI tool
update_cli_tool() {
    local cli_tool=$1
    local version=$2
    local download_url=$3

    echo "Updating $cli_tool to version $version..."

    # Download the new version
    curl -LO "$download_url"
    if [[ $? -ne 0 ]]; then
        echo "Error downloading $cli_tool from $download_url"
        exit 1
    fi

    # Make the binary executable and move it to the correct location
    chmod +x "$cli_tool-linux-amd64"
    sudo mv "$cli_tool-linux-amd64" /usr/local/bin/"$cli_tool"

    echo "$cli_tool updated to version $version"
}

# Function to get the installed version of talosctl
get_installed_talosctl_version() {
    talosctl version --short --client | awk '/Client/ {print $2}' | tr -d '"' | tr -d '[:space:]'
}

# Function to get the installed version of kubectl
get_installed_kubectl_version() {
    kubectl version --client --client | awk -F ": " '/Client Version/ {print $2}' | tr -d '"' | tr -d '[:space:]'
}

# Function to update Talosctl
update_talosctl() {
    # Extract the Talos version from talconfig
    talos_version=$(grep '^talosVersion:' "$yaml_file" | awk '{print $2}' | tr -d '"' | tr -d '[:space:]')

    if [[ -z "$talos_version" ]]; then
        echo "Error: Unable to extract Talos version from $yaml_file"
        exit 1
    fi

    echo "Talos version from talconfig: $talos_version"

    # Get the installed Talosctl version
    installed_version=$(get_installed_talosctl_version)

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

    # Define the download URL for Talosctl
    download_url="https://github.com/siderolabs/talos/releases/download/$talos_version/talosctl-linux-amd64"

    # Call the generic update function
    update_cli_tool "talosctl" "$talos_version" "$download_url"
}

# Function to update Kubectl
update_kubectl() {
    # Extract the Kubernetes version from talconfig
    kubernetes_version=$(grep '^kubernetesVersion:' "$yaml_file" | awk '{print $2}' | tr -d '"' | tr -d '[:space:]')

    if [[ -z "$kubernetes_version" ]]; then
        echo "Error: Unable to extract Kubernetes version from $yaml_file"
        exit 1
    fi

    echo "Kubernetes version from talconfig: $kubernetes_version"

    # Get the installed Kubectl version
    installed_version=$(get_installed_kubectl_version)

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

    # Define the download URL for Kubectl
    download_url="https://dl.k8s.io/release/$kubernetes_version/bin/linux/amd64/kubectl"

    # Call the generic update function
    update_cli_tool "kubectl" "$kubernetes_version" "$download_url"
}

# Main function to handle flags and call the respective update function
main() {
    if [[ $# -eq 0 ]]; then
        echo "Error: No flags provided. Use --kubectl or --talosctl to update the respective CLI tools."
        exit 1
    fi

    case "$1" in
        --kubectl)
            update_kubectl
            ;;
        --talosctl)
            update_talosctl
            ;;
        *)
            echo "Error: Invalid flag. Use --kubectl or --talosctl to update the respective CLI tools."
            exit 1
            ;;
    esac
}

# Call the main function
main "$@"
