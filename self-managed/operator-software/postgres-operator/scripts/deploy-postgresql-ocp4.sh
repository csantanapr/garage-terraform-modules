#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname $0); pwd -P)
MODULE_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)

if [[ -z "${TMP_DIR}" ]]; then
  TMP_DIR="./.tmp"
fi
mkdir -p ${TMP_DIR}

if [[ -z "${OPERATOR_NAMESPACE}" ]]; then
  OPERATOR_NAMESPACE="openshift-operators"
fi

CATALOG_SOURCE_FILE="${TMP_DIR}/csc.postgresql.yaml"

cat > "${CATALOG_SOURCE_FILE}" << EOL
apiVersion: operators.coreos.com/v1
kind: CatalogSourceConfig
metadata:
  name: postgresql
  namespace: openshift-marketplace
spec:
  targetNamespace: ${OPERATOR_NAMESPACE}
  packages: postgresql
EOL

SUBSCRIPTION_SOURCE_FILE="${TMP_DIR}/sub.postgresql.yaml"

cat > "${SUBSCRIPTION_SOURCE_FILE}" << EOL
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: postgresql
  namespace: ${OPERATOR_NAMESPACE}
spec:
  channel: alpha
  name: postgresql
  source: postgresql
  sourceNamespace: ${OPERATOR_NAMESPACE}
EOL

kubectl apply -f "${CATALOG_SOURCE_FILE}"
kubectl apply -f "${SUBSCRIPTION_SOURCE_FILE}"

until kubectl get crd/operatorconfigurations.acid.zalan.do; do
  echo "Waiting for Postgresql OperatorConfiguration CRD"
  sleep 60
done

# Set up the operator configuration
kubectl apply -f "${MODULE_DIR}/manifests/postgresql-operator-configuration.yaml" -n "${OPERATOR_NAMESPACE}"

# Patch the deployment to include env variable pointing to configuration
if [[ -z $(kubectl get deployments/postgres-operator -n "${OPERATOR_NAMESPACE}" -o jsonpath='{.spec.template.spec.containers[0].env[0].name}') ]]; then
  echo "Patching deploymemt"
  kubectl patch deployments/postgres-operator \
    -n "${OPERATOR_NAMESPACE}" \
    --type='json' \
    -p='[{"op": "add", "path": "/spec/template/spec/containers/0/env", "value": [{"name": "POSTGRES_OPERATOR_CONFIGURATION_OBJECT", "value": "postgresql-operator-configuration"}]}]'

  # Delete the pod(s) to pick up the change
  kubectl get pods -l name=postgres-operator -n "${OPERATOR_NAMESPACE}" -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | while read -r pod_name; do
    kubectl delete pod "${pod_name}" -n "${OPERATOR_NAMESPACE}"
  done
fi

until kubectl get pod -l name=postgres-operator -n "${OPERATOR_NAMESPACE}"; do
  echo "Waiting for Postgresql operator to be available"
  sleep 60
done
