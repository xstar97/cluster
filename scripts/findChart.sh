#!/bin/bash

# Define the directory to search for Helm release files
search_dir="clusters/main/kubernetes"

# Function to check if the specific environment variable is set in the chart's YAML files
check_env_var() {
    local env_var_name="$1"

    if [ -z "$env_var_name" ]; then
        echo "Error: Please provide an environment variable name using the --env flag."
        exit 1
    fi

    find "$search_dir" -type f -name "*.yaml" | while read -r file; do
        chart_name=$(basename "$(dirname "$(dirname "$file")")")
        
        # Check if the environment variable is set in the chart's YAML file
        if grep -q "env:" "$file" && grep -q "$env_var_name" "$file"; then
            echo -e "Chart: $chart_name\nPath: $file\nEnvironment Variable '$env_var_name' is set\n"
        fi
    done
}

# Main script logic
if [[ "$1" == "--check" && "$2" == "--env" && -n "$3" ]]; then
    check_env_var "$3"
else
    echo "Usage: $0 --check --env <environment_variable_name>"
    exit 1
fi
