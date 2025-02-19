#!/bin/bash

# Set the base path for the cluster
BASE_PATH="$PWD"

# Ensure a chart name is provided
if [[ -z "$1" ]]; then
    echo "Usage: hr-chart <chart-name>"
    exit 1
fi

# Find helm-release.yaml files and filter for an exact directory match
matches=($(find "$BASE_PATH/clusters/main/kubernetes" -type f -path "*/helm-release.yaml" | grep -E "/$1/"))

# Check how many matches were found
if [[ ${#matches[@]} -eq 0 ]]; then
    echo "No helm-release.yaml found for chart: $1"
    exit 1
elif [[ ${#matches[@]} -eq 1 ]]; then
    file="${matches[0]}"
else
    echo "Multiple matches found. Please select one:"
    select file in "${matches[@]}"; do
        [[ -n "$file" ]] && break
    done
fi

echo "$file"
