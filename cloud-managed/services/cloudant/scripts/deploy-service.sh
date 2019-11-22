#!/usr/bin/env bash

SERVICE_NAME="$1"
SERVICE_NAMESPACE="$2"
SERVICE_PLAN="$3"
SERVICE_CLASS="$4"
BINDING_NAME="$5"
BINDING_NAMESPACE_JSON="$6"

if [[ -z "${TMP_DIR}" ]]; then
  TMP_DIR="./tmp"
fi

YAML_FILE="${TMP_DIR}/${SERVICE_NAME}.service.yaml"

helm repo add catalyst https://ibm-garage-cloud.github.io/catalyst-charts/

helm fetch catalyst/ibmcloud-service --untar --untardir "${TMP_DIR}"

helm lint "${TMP_DIR}/ibmcloud-service"
if [[ $? -ne 0 ]]; then
  exit 1
fi

BINDING_NAMESPACES=$(echo "${BINDING_NAMESPACE_JSON}" | sed -E 's/[[](.*)[]]/{\1}/g')
echo "BINDING_NAMESPACES_JSON=${BINDING_NAMESPACE_JSON}"
echo "BINDING_NAMESPACES=${BINDING_NAMESPACES}"

helm template "${TMP_DIR}/ibmcloud-service" \
  --name "${SERVICE_NAME}" \
  --namespace "${SERVICE_NAMESPACE}" \
  --set service.plan="${SERVICE_PLAN}" \
  --set service.class="${SERVICE_CLASS}" \
  --set service.region="${REGION}" \
  --set service.location="${RESOURCE_LOCATION}" \
  --set service.resourcegroup="${RESOURCE_GROUP}" \
  --set binding.name="${BINDING_NAME}" \
  --set binding.namespaces="${BINDING_NAMESPACES}" > "${YAML_FILE}"

kubectl apply -f "${YAML_FILE}"

until [[ $(kubectl get "service.ibmcloud/${SERVICE_NAME}" -n "${SERVICE_NAMESPACE}" -o jsonpath='{.status.state}') =~ Online|Failed ]]; do
  echo ">>> Waiting for ${SERVICE_CLASS} to be ready"
  sleep 300
done

if [[ $(kubectl get "service.ibmcloud/${SERVICE_NAME}" -n "${SERVICE_NAMESPACE}" -o jsonpath='{.status.state}') == "Failed" ]]; then
  echo "*** Service deploy $SERVICE_NAME failed"
  exit 1
else
  echo ">>> ${SERVICE_NAME} is ready"
fi
