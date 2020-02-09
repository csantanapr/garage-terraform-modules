#!/bin/env bash

SOURCE_NAMESPACE="$1"
TARGET_NAMESPACE="$2"
OPERATOR_SOURCE="$3"

if [[ -n "${KUBECONFIG_IKS}" ]]; then
    export KUBECONFIG="${KUBECONFIG_IKS}"
fi

if [[ -z "${TMP_DIR}" ]]; then
  TMP_DIR="./.tmp"
fi
mkdir -p ${TMP_DIR}

OUTPUT_YAML="${TMP_DIR}/ibmcloud-operator.yaml"

cat <<EOF > "${OUTPUT_YAML}"
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: my-ibmcloud-operator
  namespace: ${TARGET_NAMESPACE}
spec:
  channel: alpha
  name: ibmcloud-operator
  source: ${OPERATOR_SOURCE}
  sourceNamespace: ${SOURCE_NAMESPACE}
EOF

kubectl apply -f "${OUTPUT_YAML}"
