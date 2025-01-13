#!/bin/bash

# Configuration
BASE_DIR="clusters/main/kubernetes/" # Directory containing HelmRelease files
EXCLUDE_NAMES="${1:-}"              # Excluded names (comma-separated, default empty)
CHARTS_MD="charts.md"               # Temporary file for charts Markdown
README_MD="README.md" # Target README file for embedding
START_MARKER="<!-- CHARTS_START -->"
END_MARKER="<!-- CHARTS_END -->"

# Parse exclusion list
IFS=',' read -r -a EXCLUDE_ARRAY <<< "$EXCLUDE_NAMES"

# Generate charts.md
echo "Generating $CHARTS_MD..."

cat <<EOF > "$CHARTS_MD"

## Helm Charts

A list of all Helm charts in the repository, sorted alphabetically.

| Name   | Namespace    | Chart     | Version  | Repository |
|--------|--------------|-----------|----------|------------|
EOF

# Find and process helm-release.yaml files
find "$BASE_DIR" -type f -name 'helm-release.yaml' | while read -r file; do
    # Extract relevant fields using yq
    NAME=$(yq '.metadata.name' "$file")
    NAMESPACE=$(yq '.metadata.namespace' "$file")
    CHART=$(yq '.spec.chart.spec.chart' "$file")
    VERSION=$(yq '.spec.chart.spec.version' "$file")
    REPO_NAME=$(yq '.spec.chart.spec.sourceRef.name' "$file")

    # Skip excluded names
    if [[ " ${EXCLUDE_ARRAY[@]} " =~ " $NAME " ]]; then
        continue
    fi

    # Append to Markdown table
    printf "| %-6s | %-12s | %-9s | %-8s | %-10s |\n" \
        "$NAME" "$NAMESPACE" "$CHART" "$VERSION" "$REPO_NAME" >> "$CHARTS_MD"
done

# Sort the table (excluding header)
{ head -n 6 "$CHARTS_MD"; tail -n +7 "$CHARTS_MD" | sort; } > "${CHARTS_MD}.sorted"
mv "${CHARTS_MD}.sorted" "$CHARTS_MD"

echo "Generated $CHARTS_MD."

# Embed charts.md into README.md
echo "Embedding $CHARTS_MD into $README_MD..."

# Expand tilde to the full path
README_MD=$(eval echo "$README_MD")

# Extract existing README content without the charts section
PRE_CHARTS=$(sed -n "/$START_MARKER/q;p" "$README_MD")
POST_CHARTS=$(sed -n "1,/$END_MARKER/!p" "$README_MD")

# Embed charts into README
{
    echo "$PRE_CHARTS"
    echo ""
    echo "$START_MARKER"
    cat "$CHARTS_MD"
    echo ""
    echo "$END_MARKER"
    echo -n "$POST_CHARTS" # Avoid unnecessary new lines
} > "$README_MD"

echo "Updated $README_MD with charts content."

# Remove temporary charts.md file
rm -f "$CHARTS_MD"
