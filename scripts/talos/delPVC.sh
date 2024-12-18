#!/bin/bash

# Define variables
CHART_NAME="qbittorrent"
CHART_NAMESPACE="qbittorrent"
PVC_NAMES="web"
HELM_RELEASE="apps/media/qbittorrent/app/helm-release.yaml"

# Get the current replica count
CURRENT_REPLICAS=$(kubectl get deployment "${CHART_NAME}" -n "${CHART_NAMESPACE}" -o jsonpath='{.spec.replicas}')
echo "Current replica count for deployment ${CHART_NAME}: ${CURRENT_REPLICAS}"

# Scale down the deployment
echo "Scaling down deployment ${CHART_NAME} in namespace ${CHART_NAMESPACE}..."
kubectl scale deployment "${CHART_NAME}" -n "${CHART_NAMESPACE}" --replicas=0

# Loop through each PVC name and delete it
IFS=',' read -ra PVC_ARRAY <<< "$PVC_NAMES"
for PVC_NAME in "${PVC_ARRAY[@]}"; do
    echo "Deleting PVC ${CHART_NAME}-${PVC_NAME} in namespace ${CHART_NAMESPACE}..."
    kubectl delete pvc "${CHART_NAME}-${PVC_NAME}" -n "${CHART_NAMESPACE}"
done

# Upgrade the Helm release using clustertool
echo "Upgrading Helm release from ${HELM_RELEASE}..."
clustertool helmrelease upgrade clusters/main/kubernetes/"${HELM_RELEASE}"

# Scale the deployment back to its original replica count
echo "Scaling deployment ${CHART_NAME} back to original replica count (${CURRENT_REPLICAS}) in namespace ${CHART_NAMESPACE}..."
kubectl scale deployment "${CHART_NAME}" -n "${CHART_NAMESPACE}" --replicas="${CURRENT_REPLICAS}"

echo "Script completed successfully."
