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
#     echo -en "\nPlease enter the namespace for the account [ENTER]: "
#     read NAMESPACE
# else
#     NAMESPACE="${1}"
# fi

if [ -z "$NAMESPACE" ]; then
    echo "ERROR: Namespace entry cannot be empty. Exiting."
    exit 1
fi



echo "INFO: Creating namespace ${NAMESPACE} in ${CLUSTER_NAME} cluster..."

if kubectl get ns "${NAMESPACE}"  &> /dev/null; then
    echo "ERROR: Namespace ${NAMESPACE} already exists in ${CLUSTER_NAME} cluster."
    exit 1
else kubectl create ns "${NAMESPACE}"
    echo "SUCCESS: Namespace ${NAMESPACE} created in ${CLUSTER_NAME} cluster."
fi



