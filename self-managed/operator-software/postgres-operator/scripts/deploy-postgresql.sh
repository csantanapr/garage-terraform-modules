#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname $0); pwd -P)
MODULE_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)

SOURCE_NAMESPACE="$1"
TARGET_NAMESPACE="$2"
OPERATOR_SOURCE="$3"

if [[ -z "${TMP_DIR}" ]]; then
  TMP_DIR="./.tmp"
fi
mkdir -p ${TMP_DIR}

OUTPUT_YAML="${TMP_DIR}/postgresql-operator.yaml"

cat <<EOF > "${OUTPUT_YAML}"
apiVersion: v1
kind: Namespace
metadata:
  name: ${TARGET_NAMESPACE}
---
apiVersion: operators.coreos.com/v1alpha2
kind: OperatorGroup
metadata:
  name: operatorgroup
  namespace: ${TARGET_NAMESPACE}
spec:
  targetNamespaces:
  - ${TARGET_NAMESPACE}
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: my-postgresql
  namespace: ${TARGET_NAMESPACE}
spec:
  channel: stable
  name: postgresql
  source: ${OPERATOR_SOURCE}
  sourceNamespace: ${SOURCE_NAMESPACE}
EOF

kubectl apply -f "${OUTPUT_YAML}"
