#!/bin/bash

# Define the directory to search for Helm release files
search_dir="clusters/main/kubernetes"

# Function to search for the keyword in Helm release files
search_keyword() {
    local keyword="$1"

    if [ -z "$keyword" ]; then
        echo "Error: Please provide a keyword to search using the --keyword flag."
        exit 1
    fi

    # Find all helm-release.yaml files in the search directory
    find "$search_dir" -type f -name "helm-release.yaml" | while read -r file; do
        # Extract the chart name based on directory structure
        chart_name=$(basename "$(dirname "$(dirname "$file")")")

        # Check if the keyword is present in the chart's YAML file
        if grep -q "$keyword" "$file"; then
            echo -e "Chart: $chart_name\nPath: $file\n"
            echo
        fi
    done
}

# Main script logic
if [[ "$1" == "--check" && "$2" == "--keyword" && -n "$3" ]]; then
    search_keyword "$3"
else
    echo "Usage: $0 --check --keyword <keyword_to_search>"
    exit 1
fi
