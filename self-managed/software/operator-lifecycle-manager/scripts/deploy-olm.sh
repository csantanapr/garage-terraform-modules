#!/usr/bin/env bash

OLM_VERSION="$1"
CLUSTER_VERSION="$2"

if [[ -n "${KUBECONFIG_IKS}" ]]; then
  export KUBECONFIG="${KUBECONFIG_IKS}"
fi

if [[ "${CLUSTER_VERSION}" =~ 4[.].* ]]; then
  echo "Cluster version already has OLM: ${CLUSTER_VERSION}"
  exit 0
fi

curl -sL "https://github.com/operator-framework/operator-lifecycle-manager/releases/download/${OLM_VERSION}/install.sh" | bash -s "${OLM_VERSION}"
