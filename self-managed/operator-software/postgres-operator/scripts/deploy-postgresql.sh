#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname $0); pwd -P)
MODULE_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)

OPERATOR_NAMESPACE="$1"

if [[ -n "${KUBECONFIG_IKS}" ]]; then
    export KUBECONFIG="${KUBECONFIG_IKS}"
fi

if [[ -z "${TMP_DIR}" ]]; then
    TMP_DIR=".tmp"
fi
mkdir -p ${TMP_DIR}

kubectl create -f https://operatorhub.io/install/postgres-operator.yaml

until kubectl get crd/operatorconfigurations.acid.zalan.do; do
  echo "Waiting for Postgresql OperatorConfiguration CRD"
  sleep 60
done

# Set up the operator configuration
kubectl apply -f "${MODULE_DIR}/manifests/postgresql-operator-configuration.yaml" -n "${OPERATOR_NAMESPACE}"

# Patch the deployment to include env variable pointing to configuration
if [[ -z $(kubectl get deployments/postgres-operator -n operators -o jsonpath='{.spec.template.spec.containers[0].env[0].name}') ]]; then
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
