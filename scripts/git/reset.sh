#!/bin/bash

# Set the base path for the cluster
BASE_PATH="$PWD"

# Source the utility file
source $BASE_PATH/scripts/utils.sh

# Check if the following are installed
check_command "git"

# Reset to a new initial commit and force push to the main branch
git reset $(git commit-tree HEAD^{tree} -m 'Initial commit') && git push --force origin main
