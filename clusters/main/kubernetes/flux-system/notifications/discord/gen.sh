#!/usr/bin/env bash
# File: gen.sh

OUTPUT_FILE="clusters/main/kubernetes/flux-system/notifications/discord/notification.yaml"

# Start YAML
cat > "$OUTPUT_FILE" <<'EOF'
apiVersion: notification.toolkit.fluxcd.io/v1beta3
kind: Alert
metadata:
  name: discord
  namespace: flux-system
spec:
  providerRef:
    name: discord
  eventSeverity: info
  eventSources:
EOF

# Loop through all namespaces
for ns in $(kubectl get ns -o jsonpath='{.items[*].metadata.name}'); do
    # Check if the namespace has at least one HelmRelease
    if kubectl get helmrelease -n "$ns" --no-headers &>/dev/null; then
        cat >> "$OUTPUT_FILE" <<EOF
    - kind: HelmRelease
      name: "*"
      namespace: $ns
EOF
    fi
done

echo "Alert YAML generated successfully at $OUTPUT_FILE"
echo "--------------------------------------------"
cat "$OUTPUT_FILE"
