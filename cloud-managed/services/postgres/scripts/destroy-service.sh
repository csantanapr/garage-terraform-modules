#!/usr/bin/env bash

SERVICE_NAME="$1"
SERVICE_NAMESPACE="$2"
BINDING_NAME="$3"

kubectl delete "bindings.ibmcloud/${BINDING_NAME}" -A
kubectl delete "services.ibmcloud/${SERVICE_NAME}" -n "${SERVICE_NAMESPACE}"
