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



if kubectl get sa "${NAMESPACE}-sa" -n "${NAMESPACE}" &> /dev/null; then
    echo "INFO: Service account ${NAMESPACE}-sa already exists in namespace ${NAMESPACE}."
    SERVER=$(kubectl config view --minify --output=jsonpath='{.clusters[?(@.name == '\"${CLUSTER_NAME}\"')].cluster.server}')
    SECRET=$(kubectl get secrets --namespace "${NAMESPACE}" | awk "/${NAMESPACE}-sa/"'{print $1}')
    CA_CERT=$(kubectl get --namespace "${NAMESPACE}" "secret/${SECRET}" -o jsonpath='{.data.ca\.crt}')
    TOKEN=$(kubectl get --namespace "${NAMESPACE}" "secret/${SECRET}" -o jsonpath='{.data.token}' | base64 --decode)
    OUTPUT_FILE="${NAMESPACE}-kubeconfig.yaml"
    echo -e "INFO: I'm writing out your new kubeconfig to: $(pwd)/${OUTPUT_FILE}"

cat << EOF > "${OUTPUT_FILE}"
---
apiVersion: v1
kind: Config
clusters:
- name: ${CLUSTER_NAME}
  cluster:
    certificate-authority-data: ${CA_CERT}
    server: ${SERVER}
contexts:
- name: ${NAMESPACE}@${CLUSTER_NAME}
  context:
    cluster: ${CLUSTER_NAME}
    namespace: ${NAMESPACE}
    user: ${NAMESPACE}-sa
current-context: ${NAMESPACE}@${CLUSTER_NAME}
users:
- name: ${NAMESPACE}-sa
  user:
    token: ${TOKEN}
EOF

    echo -e "INFO: Kubeconfig is complete."
else
    echo "ERROR: ${NAMESPACE}-sa service account does not exist in ${NAMESPACE} namespace. Exiting."
    exit 1
    
fi

export KUBECONFIG_VARIABLE=$(cat $(pwd)/${OUTPUT_FILE} | base64 -w0)
echo "KUBECONFIG_VARIABLE=$KUBECONFIG_VARIABLE" >> kubeconfig.env





