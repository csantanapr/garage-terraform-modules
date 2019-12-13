#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname $0); pwd -P)
MODULE_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)

NAMESPACE="$1"
INSTANCE_NAME="$2"
DATABASE_OWNER="$3"
DATABASE_NAME="$4"

OPERATOR_NAMESPACE="operators"

if [[ -n "${KUBECONFIG_IKS}" ]]; then
    export KUBECONFIG="${KUBECONFIG_IKS}"
fi

if [[ -z "${TMP_DIR}" ]]; then
    TMP_DIR=".tmp"
fi
mkdir -p ${TMP_DIR}

POSTGRES_YAML="${TMP_DIR}/${NAMESPACE}-postgresql.yaml"

kubectl create -f https://operatorhub.io/install/postgres-operator.yaml

# Set up the operator configuration
kubectl apply -f "${MODULE_DIR}/manifests/postgresql-operator-configuration.yaml" -n "${OPERATOR_NAMESPACE}"

# Patch the deployment to include env variable pointing to configuration
kubectl patch deployents/postgres-operator \
  -n "${OPERATOR_NAMESPACE}" \
  --type json \
  -p '[{"op": "add", "path": "/spec/containers/env/0", "value": {"name": "POSTGRES_OPERATOR_CONFIGURATION_OBJECT", "value": "postgresql-operator-configuration"}}]'

# Delete the pod?

until kubectl get pod -l name=postgres-operator -n "${OPERATOR_NAMESPACE}"; do
  echo "Postgresql operator available"
done

helm template "${MODULE_DIR}/charts/postgresql" \
  --set instanceName="${INSTANCE_NAME}" \
  --set databaseOwner="${DATABASE_OWNER}" \
  --set databaseName="${DATABASE_NAME}" > "${POSTGRES_YAML}"
kubectl create -n "${NAMESPACE}" -f "${POSTGRES_YAML}"
