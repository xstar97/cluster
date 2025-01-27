#!/bin/bash

# Source the utility file
source /workspaces/cluster/scripts/utils.sh

# Check if the following are installed
check_command "helm"

# Define the OCI repository URL
REPO_URL="oci://tccr.io/truecharts"

# Function to fetch and display specific fields from the chart YAML
fetch_chart_info() {
  local chart_name="$1"
  local app_version=""
  local version=""
  local home=""

  # Fetch chart YAML and extract relevant fields
  while IFS= read -r line; do
    case "$line" in
      appVersion:*) app_version="${line#appVersion: }" ;;
      version:*) version="${line#version: }" ;;
      home:*) home="${line#home: }" ;;
    esac
  done < <(helm show chart "$REPO_URL/$chart_name" 2>/dev/null)

  # Return the results
  echo "$app_version" "$version" "$home"
}

# Function to display chart information
display_chart_info() {
  local chart_name="$1"
  local info
  info=$(fetch_chart_info "$chart_name")

  # Split the output into an array
  IFS=' ' read -r app_version version home <<< "$info"

  # Print in the desired format if fields are not empty
  if [[ -n "$app_version" ]]; then
    echo "Fetching details for chart '$chart_name'..."
    [[ -n "$app_version" ]] && echo "appVersion: $app_version"
    [[ -n "$version" ]] && echo "version: $version"
    [[ -n "$home" ]] && echo "home: $home"
  else
    echo "No details found for chart '$chart_name'."
  fi
}

# Main script logic
if [[ "$1" == "--chart" && -n "$2" ]]; then
  display_chart_info "$2"
else
  echo "Usage: $0 --chart <chart-name>"
fi
