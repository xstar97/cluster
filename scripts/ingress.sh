#!/bin/bash

# Define the directory to search for Helm release files
search_dir="clusters/main/kubernetes"

# Function to check ingress in Helm release files
check_ingress() {
    find "$search_dir" -type f -name "*.yaml" | while read -r file; do
        chart_name=$(basename "$(dirname "$(dirname "$file")")")
        if grep -q "ingress:" "$file"; then
            if grep -q "enabled: true" "$file"; then
                ingress_enabled="enabled"
            else
                ingress_enabled="disabled"
            fi
            echo -e "Chart: $chart_name\nPath: $file\nIngress: $ingress_enabled\n"
        fi
    done
}

# Function to toggle ingress state (enable/disable)
toggle_ingress() {
    local enable=$1
    local new_state=$(if [ "$enable" = true ]; then echo "true"; else echo "false"; fi)

    find "$search_dir" -type f -name "*.yaml" | while read -r file; do
        if grep -q "ingress:" "$file"; then
            sed -i "/ingress:/,/enabled:/s/enabled: [a-z]*/enabled: $new_state/" "$file"
            echo "Ingress ${new_state}d for: $file"
        fi
    done
}

# Main script logic
case "$1" in
    --check)
        check_ingress
        ;;
    --enabled)
        toggle_ingress true
        ;;
    --disabled)
        toggle_ingress false
        ;;
    *)
        echo "Usage: $0 --check | --enabled | --disabled"
        exit 1
        ;;
esac
