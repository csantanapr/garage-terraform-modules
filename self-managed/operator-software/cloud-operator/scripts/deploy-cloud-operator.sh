#!/bin/env bash

RESOURCE_GROUP="$1"
REGION="$2"

if [[ -n "${KUBECONFIG_IKS}" ]]; then
    export KUBECONFIG="${KUBECONFIG_IKS}"
fi

kubectl create -f https://operatorhub.io/install/ibmcloud-operator.yaml

export IC_APIKEY="${APIKEY}"
ibmcloud login --apikey "${APIKEY}" -r "${REGION}" -g "${RESOURCE_GROUP}" 1> /dev/null 2> /dev/null

curl -sL https://raw.githubusercontent.com/IBM/cloud-operators/master/hack/config-operator.sh | bash