#!/bin/bash

# Define file paths
CONTROLPLANE_YAML="/workspaces/cluster/clusters/main/talos/generated/main-k8s-control-1.yaml"
SECRETS_YAML="/workspaces/cluster/clusters/main/talos/generated/talsecret.yaml"
TALOSCONFIG="/workspaces/cluster/clusters/main/talos/generated/talosconfig"
CA_CRT="ca.crt"
CA_KEY="ca.key"
ADMIN_CRT="admin.crt"
ADMIN_KEY="admin.key"
ADMIN_CSR="admin.csr"
CONTROL_PLANE_IP="127.0.0.1" #10.0.0.191"  # Update this with the actual control plane IP
NODES="main"  # Update this with the correct none

# Step 1: Create talosconfig using talosctl
echo "Creating talosconfig using talosctl..."
talosctl gen config --with-secrets "$SECRETS_YAML" --output-types talosconfig -o "$TALOSCONFIG" main "https://10.0.0.191" --force

# Step 2: Extract the CA cert and key from the control plane config
echo "Extracting CA certificate and key from controlplane.yaml..."
yq eval .machine.ca.crt "$CONTROLPLANE_YAML" | base64 -d > "$CA_CRT"
yq eval .machine.ca.key "$CONTROLPLANE_YAML" | base64 -d > "$CA_KEY"

# Check if files are created successfully
if [[ ! -f "$CA_CRT" || ! -f "$CA_KEY" ]]; then
  echo "Error: Failed to extract CA cert or key."
  exit 1
fi

# Step 3: Generate fresh credentials (admin key, CSR, and cert)
echo "Generating fresh credentials..."
talosctl gen key --name admin --force
talosctl gen csr --key "$ADMIN_KEY" --ip "$CONTROL_PLANE_IP" --force

# Correct the crt command:
talosctl gen crt --ca "${CA_CRT%.*}" --csr "$ADMIN_CSR" --name admin --force

# Check if credentials were generated
if [[ ! -f "$ADMIN_KEY" || ! -f "$ADMIN_CSR" || ! -f "$ADMIN_CRT" ]]; then
  echo "Error: Failed to generate credentials."
  exit 1
fi

# Step 4: Update the talosconfig with the new base64-encoded credentials
echo "Updating talosconfig with base64-encoded credentials..."
yq eval '.contexts.main.ca = "'"$(base64 -w0 "$CA_CRT")"'" | .contexts.main.crt = "'"$(base64 -w0 "$ADMIN_CRT")"'" | .contexts.main.key = "'"$(base64 -w0 "$ADMIN_KEY")"'"' -i "$TALOSCONFIG"

# Step 5: Directly save and update Kubernetes config
echo "Updating Kubernetes config with new credentials..."
talosctl kubeconfig -n "$NODES" -e "https://$CONTROL_PLANE_IP" --talosconfig "$TALOSCONFIG" --force

echo "Script execution completed."

