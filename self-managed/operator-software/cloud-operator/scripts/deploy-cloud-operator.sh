#!/bin/env bash

REGION="$1"
SOURCE_NAMESPACE="$2"
TARGET_NAMESPACE="$3"
OPERATOR_SOURCE="$4"

if [[ -n "${KUBECONFIG_IKS}" ]]; then
    export KUBECONFIG="${KUBECONFIG_IKS}"
fi

if [[ -z "${TMP_DIR}" ]]; then
  TMP_DIR="./.tmp"
fi
mkdir -p ${TMP_DIR}

if [[ -z "${APIKEY}" ]]; then
  echo "APIKEY is missing"
  exit 1
fi

if [[ -z "${RESOURCE_GROUP}" ]]; then
  echo "RESOURCE_GROUP is missing"
  exit 1
fi

OUTPUT_YAML="${TMP_DIR}/ibmcloud-operator.yaml"

cat <<EOF > "${OUTPUT_YAML}"
apiVersion: v1
kind: Secret
metadata:
  name: seed-secret
  labels:
    seed.ibm.com/ibmcloud-token: "apikey"
    app.kubernetes.io/name: ibmcloud-operator
  namespace: default
type: Opaque
stringData:
  api-key: "${APIKEY}"
  region: "${REGION}"
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: seed-defaults
  namespace: default
  labels:
    app.kubernetes.io/name: ibmcloud-operator
data:
  org: ""
  space: ""
  region: "${REGION}"
  resourceGroup: "${RESOURCE_GROUP}"
---
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
