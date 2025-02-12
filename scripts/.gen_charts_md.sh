#!/bin/bash

# Source the utility file
source /workspaces/cluster/scripts/utils.sh

# Check if yq is installed
check_command "yq"

# Configuration
BASE_DIR="clusters/main/kubernetes/"  # Directory containing HelmRelease files
EXCLUDE_NAMES="${1:-}"                # Excluded names (comma-separated, default empty)
CHARTS_MD="charts.md"                 # Temporary file for charts Markdown
README_MD="README.md"                 # Target README file for embedding
START_MARKER="<!-- CHARTS_START -->"
END_MARKER="<!-- CHARTS_END -->"

# Sorting options: name, namespace, chart, version, repository
SORT_BY="${SORT_BY:-name}"

# Parse exclusion list
IFS=',' read -r -a EXCLUDE_ARRAY <<< "$EXCLUDE_NAMES"

# Create Markdown header
echo "Generating $CHARTS_MD..."

cat <<EOF > "$CHARTS_MD"
## Helm Charts

A list of all Helm charts in the repository, sorted by **$SORT_BY**.

| Name          | Namespace      | Chart         | Version  | Repository  |
|--------------|---------------|--------------|---------|------------|
EOF

# Find and process helm-release.yaml files
TEMP_FILE=$(mktemp)
while IFS= read -r file; do
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

    # Store entries in a temporary file
    echo "$NAME|$NAMESPACE|$CHART|$VERSION|$REPO_NAME" >> "$TEMP_FILE"

done < <(find "$BASE_DIR" -type f -name 'helm-release.yaml')

# Sort the table based on user preference
case "$SORT_BY" in
    name) sort -t'|' -k1 ;;
    namespace) sort -t'|' -k2 ;;
    chart) sort -t'|' -k3 ;;
    version) sort -t'|' -k4V ;;  # Version-aware sorting
    repository) sort -t'|' -k5 ;;
    *) sort -t'|' -k1 ;;  # Default to sorting by name
esac < "$TEMP_FILE" >> "$CHARTS_MD"

rm -f "$TEMP_FILE"

echo "Generated $CHARTS_MD."

# Embed charts.md into README.md
echo "Embedding $CHARTS_MD into $README_MD..."

# Expand tilde to full path
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
    echo "$POST_CHARTS"
} > "$README_MD"

echo "Updated $README_MD with charts content."
