#!/bin/bash

# Define the YAML file path
CONFIG="clusters/main/clusterenv.yaml"

# Source the utility file
source /workspaces/cluster/scripts/utils.sh

# Check if the following are installed
check_command "yq"
check_command "git"

# Check if the YAML file exists
if [ ! -f "$CONFIG" ]; then
  echo "Error: $CONFIG not found!"
  exit 1
fi

# Read values from the YAML file using yq
GITHUB_USER=$(yq eval '.GITHUB_USER' "$CONFIG")
GITHUB_EMAIL=$(yq eval '.GITHUB_EMAIL' "$CONFIG")

# Check if the values are empty
if [ -z "$GITHUB_USER" ] || [ -z "$GITHUB_EMAIL" ]; then
  echo "Error: GitHub username or email is missing in the YAML file!"
  exit 1
fi

# Echo the values to confirm
echo "Setting Git username to: $GITHUB_USER"
echo "Setting Git email to: $GITHUB_EMAIL"

# Set the Git username and email globally
git config --global user.name "$GITHUB_USER"
git config --global user.email "$GITHUB_EMAIL"

echo "Git username and email have been set successfully!"
