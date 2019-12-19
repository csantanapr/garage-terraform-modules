#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname $0); pwd -P)
MODULE_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)

NAMESPACE="$1"
INSTANCE_NAME="$2"
DATABASE_OWNER="$3"
DATABASE_NAME="$4"
STORAGE_CLASS="$5"

if [[ -n "${KUBECONFIG_IKS}" ]]; then
    export KUBECONFIG="${KUBECONFIG_IKS}"
fi

if [[ -z "${TMP_DIR}" ]]; then
    TMP_DIR=".tmp"
fi
mkdir -p ${TMP_DIR}

POSTGRES_YAML="${TMP_DIR}/${NAMESPACE}-postgresql.yaml"

helm template "${MODULE_DIR}/charts/postgresql" \
  --set instanceName="${INSTANCE_NAME}" \
  --set databaseOwner="${DATABASE_OWNER}" \
  --set databaseName="${DATABASE_NAME}" \
  --set storageClass="${STORAGE_CLASS}" \
  --set teamId="${NAMESPACE}" > "${POSTGRES_YAML}"
kubectl create -n "${NAMESPACE}" -f "${POSTGRES_YAML}"
