#!/bin/bash

# Define the directory to search for Helm release files
search_dir="clusters/main/kubernetes"

# Function to check if global stopAll is enabled
check_global_stopAll() {
    find "$search_dir" -type f -name "*.yaml" | while read -r file; do
        chart_name=$(basename "$(dirname "$(dirname "$file")")")
        if grep -q "global:" "$file"; then
            if grep -q "stopAll: true" "$file"; then
                stopAll_state="enabled"
            else
                stopAll_state="disabled"
            fi
            echo -e "Chart: $chart_name\nPath: $file\nstopAll: $stopAll_state\n"
        fi
    done
}

# Function to toggle global stopAll state (enable/disable)
toggle_global_stopAll() {
    local enable=$1
    local new_state=$(if [ "$enable" = true ]; then echo "true"; else echo "false"; fi)

    find "$search_dir" -type f -name "*.yaml" | while read -r file; do
        if grep -q "global:" "$file"; then
            sed -i "/global:/,/stopAll:/s/stopAll: [a-z]*/stopAll: $new_state/" "$file"
            echo "stopAll ${new_state}d for: $file"
        fi
    done
}

# Main script logic
case "$1" in
    --check)
        check_global_stopAll
        ;;
    --enabled)
        toggle_global_stopAll true
        ;;
    --disabled)
        toggle_global_stopAll false
        ;;
    *)
        echo "Usage: $0 --check | --enabled | --disabled"
        exit 1
        ;;
esac
