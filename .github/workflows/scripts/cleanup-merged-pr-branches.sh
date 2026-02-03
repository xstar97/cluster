#!/bin/bash
set -euo pipefail

# Ensure GITHUB_TOKEN is set
if [ -z "${GITHUB_TOKEN:-}" ]; then
    echo "GITHUB_TOKEN is required"
    exit 1
fi

# Fetch all remote branches
git fetch origin --prune

echo "Fetching all merged PRs..."
merged_branches=$(gh pr list --state closed --search "is:merged" --json headRefName --jq '.[].headRefName')

# Initialize logs
deleted=""
skipped=""

for branch in $merged_branches; do
    # Skip main
    if [ "$branch" = "main" ]; then
        skipped+="$branch (main)\n"
        continue
    fi

    # Check if branch exists on remote
    if git ls-remote --exit-code --heads origin "$branch" &>/dev/null; then
        git push origin --delete "$branch"
        deleted+="$branch\n"
    else
        skipped+="$branch (already deleted)\n"
    fi
done

# Output summary for GitHub Actions
echo "### Cleanup Summary" >> $GITHUB_STEP_SUMMARY
echo "**Deleted branches:**" >> $GITHUB_STEP_SUMMARY
if [ -n "$deleted" ]; then
    echo -e "$deleted" >> $GITHUB_STEP_SUMMARY
else
    echo "_None_" >> $GITHUB_STEP_SUMMARY
fi

echo "**Skipped branches:**" >> $GITHUB_STEP_SUMMARY
if [ -n "$skipped" ]; then
    echo -e "$skipped" >> $GITHUB_STEP_SUMMARY
else
    echo "_None_" >> $GITHUB_STEP_SUMMARY
fi

echo "Cleanup completed."
