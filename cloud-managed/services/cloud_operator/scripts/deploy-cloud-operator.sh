#!/bin/env bash

RESOURCE_GROUP="$1"
REGION="$2"

ibmcloud login --apikey "${APIKEY}" -r "${REGION}" -g "${RESOURCE_GROUP}"

export IC_APIKEY="${APIKEY}"
curl -sL https://raw.githubusercontent.com/IBM/cloud-operators/master/hack/install-operator.sh | bash
