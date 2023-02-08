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
#     echo -en "\nPlease enter the namespace for this account [ENTER]: "
#     read NAMESPACE
# else
#     NAMESPACE="${1}"
# fi

if [ -z "$NAMESPACE" ]; then
    echo "ERROR: Namespace name cannot be empty. Exiting."
    exit 1
fi

if kubectl get ns "${NAMESPACE}" &> /dev/null; then
    echo "INFO: Creating role and role binding"
    # kubectl create role -n $NAMESPACE $NAMESPACE-role --resource='*' --verb='*'
cat << EOF | kubectl apply -f -
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: $NAMESPACE-role
  namespace: $NAMESPACE
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
EOF

    kubectl create rolebinding -n $NAMESPACE $NAMESPACE-rolebinding --role=$NAMESPACE-role \
    --serviceaccount=$NAMESPACE:$NAMESPACE-sa
else
    echo "ERROR: Namespace $NAMESPACE does not exist. Exiting."
    exit 1
fi



