#!/bin/bash

# Source the utility file
source /workspaces/cluster/scripts/utils.sh

# Check if kubectl is installed
check_command "kubectl"

# Check if column is installed, and provide installation instructions if missing
if ! command -v column &>/dev/null; then
    echo "Error: 'column' command not found. Please install 'util-linux' using:"
    echo "  Debian/Ubuntu: sudo apt install util-linux"
    echo "  CentOS/RHEL: sudo dnf install util-linux"
    echo "  Alpine Linux: sudo apk add util-linux"
    echo "  Arch Linux: sudo pacman -S util-linux"
    exit 1
fi

# Get namespaces and secret names
namespaces=$(kubectl get secrets -A | grep -E "dbcreds|cnpg-main-urls" | awk '{print $1, $2}')

# Print header
( printf "Application | Username | Password | Address | Port\n"
echo "$namespaces" | while read -r ns secret; do
    # Extract application name
    app_name="$ns"

    # Retrieve secret data
    if [ "$secret" = "dbcreds" ]; then
        creds=$(kubectl get secret "$secret" --namespace "$ns" -o jsonpath='{.data.url}' | base64 -d 2>/dev/null)
    else
        creds=$(kubectl get secret "$secret" --namespace "$ns" -o jsonpath='{.data.std}' | base64 -d 2>/dev/null)
    fi

    # Skip if creds are empty
    if [ -z "$creds" ]; then
        continue
    fi

    # Expected format: protocol://username:password@host:port/database
    # Extract username
    username=$(echo "$creds" | sed -E 's#^.*://([^:@]+):.*@\S+#\1#')

    # Extract password
    password=$(echo "$creds" | sed -E 's#^.*://[^:@]+:([^@]+)@\S+#\1#')

    # Extract host address
    addresspart=$(echo "$creds" | sed -E 's#^.*@([^:/]+):?.*#\1#')

    # Extract port
    port=$(echo "$creds" | sed -E 's#^.*:([0-9]+)/.*#\1#')

    # Construct full address
    full_address="${addresspart}.${ns}.svc.cluster.local"

    # Print results
    printf "%s | %s | %s | %s | %s\n" "$app_name" "$username" "$password" "$full_address" "$port"
done ) | column -t -s "|"
