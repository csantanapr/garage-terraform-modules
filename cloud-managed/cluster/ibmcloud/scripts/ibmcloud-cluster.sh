#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname $0); pwd -P)
ROOT_DIR=$(cd "${SCRIPT_DIR}/../.."; pwd -P)

RESOURCE_GROUP="$1"
if [[ -z "${RESOURCE_GROUP}" ]]; then
  echo "RESOURCE_GROUP is required as 1st parameter"
  exit 1
fi

REGION="$2"
if [[ -z "${REGION}" ]]; then
  echo "REGION is required as 2nd parameter"
  exit 1
fi

CLUSTER_NAME="$3"
if [[ -z "${CLUSTER_NAME}" ]]; then
  echo "CLUSTER_NAME is required as 3rd parameter"
  exit 1
fi

CLUSTER_TYPE="$4"
if [[ -z "${CLUSTER_TYPE}" ]]; then
  echo "CLUSTER_TYPE is required as 4th parameter"
  exit 1
fi

SERVER_URL="$5"
if [[ -z "${SERVER_URL}" ]]; then
  echo "SERVER_URL is required as 5th parameter"
  exit 1
fi

if [[ -z "${APIKEY}" ]]; then
  echo "APIKEY is required either as an environment variable"
  exit 1
fi

export IKS_BETA_VERSION=1.0

ibmcloud config --check-version=false 1> /dev/null 2> /dev/null

echo "Logging into ibmcloud: ${REGION}/${RESOURCE_GROUP}"
ibmcloud login \
  --apikey "${APIKEY}" \
  -g "${RESOURCE_GROUP}" \
  -r "${REGION}" 1> /dev/null 2> /dev/null

echo "  Determining cluster type"
OPENSHIFT=$(ibmcloud ks cluster get --cluster "${CLUSTER_NAME}" | grep Version | grep openshift)
if [[ -z "${OPENSHIFT}" ]]; then
  echo "Logging into IKS cluster: ${CLUSTER_NAME}"
  ibmcloud ks cluster config --cluster "${CLUSTER_NAME}" 1> /dev/null 2> /dev/null
else
  echo "Logging into OpenShift cluster: ${CLUSTER_NAME}"
  oc login -u apikey -p "${APIKEY}" --server="${SERVER_URL}" 1> /dev/null 2> /dev/null
fi
