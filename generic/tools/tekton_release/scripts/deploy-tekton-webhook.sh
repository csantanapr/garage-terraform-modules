#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname $0); pwd -P)

NAMESPACE="$1"
INGRESS_SUBDOMAIN="$2"

curl -L https://github.com/tektoncd/dashboard/releases/latest/download/openshift-tekton-webhooks-extension-release.yaml \
  | sed -e "s/{openshift_master_default_subdomain}/${INGRESS_SUBDOMAIN}/g" \
  | oc apply -n ${NAMESPACE} --filename -
