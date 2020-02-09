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

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: ${TARGET_NAMESPACE}
---
apiVersion: operators.coreos.com/v1alpha2
kind: OperatorGroup
metadata:
  name: operatorgroup
  namespace: my-postgresql
spec:
  targetNamespaces:
  - my-postgresql
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: my-postgresql
  namespace: my-postgresql
spec:
  channel: stable
  name: postgresql
  source: ${OPERATOR_SOURCE}
  sourceNamespace: ${SOURCE_NAMESPACE}
EOF
