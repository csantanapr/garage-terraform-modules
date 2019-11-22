#!/bin/env bash

CREDENTIALS_FILE="$1"

cat "${CREDENTIALS_FILE}" | sed -E "s/.*ingestion_key\": {0,1}\"([^\"]*)\".*/\1/" | xargs -I{} echo -n {}
