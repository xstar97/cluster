#!/bin/bash

# Source the utility file
source /workspaces/cluster/scripts/utils.sh

# Check if the following are installed
check_command "kubectl"

# Get all PVCs with namespace/name
all_pvcs=$(kubectl get pvc --all-namespaces -o jsonpath='{range .items[*]}{.metadata.namespace}/{.metadata.name}{"\n"}{end}')
all_pvc_count=$(echo "$all_pvcs" | wc -l)

# Get all PVCs used by pods
used_pvcs=$(kubectl get pods --all-namespaces -o jsonpath='{range .items[*].spec.volumes[*]}{.persistentVolumeClaim.claimName}{"\n"}{end}' | sort -u)
used_pvc_count=$(echo "$used_pvcs" | wc -l)

# Identify PVCs not used by any pods
unused_pvcs=()
for pvc in $all_pvcs; do
  pvc_name=$(basename "$pvc")
  if ! echo "$used_pvcs" | grep -qw "$pvc_name"; then
    unused_pvcs+=("$pvc")
  fi
done

unused_pvc_count=${#unused_pvcs[@]}

# Output results
echo "Total PVCs: $all_pvc_count"
echo "Used PVCs: $used_pvc_count"
echo "Unused PVCs: $unused_pvc_count"

if [ "$((used_pvc_count + unused_pvc_count))" -eq "$all_pvc_count" ]; then
  echo "All PVCs are accounted for."
else
  echo "Warning: Discrepancy in PVC count!"
fi

# List unused PVCs, if any
if [ "$unused_pvc_count" -gt 0 ]; then
  echo "Unused PVCs:"
  for pvc in "${unused_pvcs[@]}"; do
    echo "  $pvc"
  done
else
  echo "No unused PVCs found."
fi
