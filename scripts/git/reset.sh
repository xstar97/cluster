#!/bin/bash

# Function to check if a command is installed
check_command() {
  if ! command -v "$1" &> /dev/null; then
    echo "Error: $1 is not installed. Please install it before running this script."
    exit 1
  fi
}

# Check if git is installed
check_command "git"

# Reset to a new initial commit and force push to the main branch
git reset $(git commit-tree HEAD^{tree} -m 'Initial commit') && git push --force origin main
