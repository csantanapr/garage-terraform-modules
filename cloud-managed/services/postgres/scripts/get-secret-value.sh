#!/usr/bin/env bash

NAME="$1"
NAMESPACE="$2"
KEY="$3"

kubectl get "secret/${NAME}" -n "${NAMESPACE}" -o "jsonpath={.data.${KEY}}" | base64 -D | xargs -I{} echo -n {}
