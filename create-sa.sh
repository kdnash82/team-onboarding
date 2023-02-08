#!/bin/bash

set -eu

# Check for kubectl cli
if ! command -v kubectl > /dev/null; then
    echo -e "\nERROR: The kubectl CLI is required to run this helper script. Exiting."
    exit 1
fi

# Check current Kubernetes Context
echo -e "\nINFO: Checking the current Kubernetes context..."
CONTEXT=$(kubectl config current-context)
CLUSTER_NAME=$(kubectl config view --minify --output=jsonpath='{.clusters[].name}')
echo "INFO: Current context is set to: ${CONTEXT}."

# if [[ "${#}" -ne 1 ]]; then
#     echo -en "\nPlease enter the service account name [ENTER]: "
#     read SERVICE_ACCOUNT
# else
#     SERVICE_ACCOUNT="${1}"
# fi

if [ -z "$NAMESPACE" ]; then
    echo "ERROR: Service account name cannot be empty. Exiting."
    exit
fi

# NAMESPACE="${2:-$SERVICE_ACCOUNT}"

echo "INFO: Creating service account ${NAMESPACE}-sa in namespace ${NAMESPACE}..."

if kubectl get sa "${NAMESPACE}-sa" -n "${NAMESPACE}" &> /dev/null; then
    echo "ERROR: Service account ${NAMESPACE}-sa already exists in namespace ${NAMESPACE}. Exiting."
    exit 1
else kubectl create sa "${NAMESPACE}-sa" -n "${NAMESPACE}"
      echo "SUCCESS: Service account ${NAMESPACE}-sa created in namespace ${NAMESPACE}."
fi



