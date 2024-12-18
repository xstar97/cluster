#!/bin/bash

# Define the directory to search for Helm release files
search_dir="clusters/main/kubernetes"
py_get_s3_items="/home/cluster/scripts/S3/getS3BucketItems.py"

# Define the list of charts to exclude from validation
VOLSYNC_LIST=$(python3 $py_get_s3_items)

# Convert VOLSYNC_LIST into an array for easy comparison
IFS=',' read -r -a VOLSYNC_ARRAY <<< "$VOLSYNC_LIST"

# Function to check for s3 credentials and cloudflare in charts not in VOLSYNC_LIST
check_s3() {
    find "$search_dir" -type f -name "*.yaml" | while read -r file; do
        chart_name=$(basename "$(dirname "$(dirname "$file")")")
        
        # Skip charts that are in the VOLSYNC_LIST
        if [[ " ${VOLSYNC_ARRAY[*]} " =~ " ${chart_name} " ]]; then
            continue
        fi
        
        # Check if "credentials:" and "cloudflare" exist in the file
        if grep -q "credentials:" "$file" && grep -q "cloudflare" "$file"; then
            echo -e "Chart: $chart_name\nPath: $file\nCredentials and Cloudflare entry found\n"
        fi
    done
}

# Main script logic
case "$1" in
    --check)
        check_s3
        ;;
    *)
        echo "Usage: $0 --check"
        exit 1
        ;;
esac
