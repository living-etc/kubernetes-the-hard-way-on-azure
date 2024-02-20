#! /usr/bin/env bash

set -exuo pipefail

RESOURCE_GROUP="Kubernetes-The-Hard-Way"

KUBERNETES_PUBLIC_ADDRESS=$(
  az network public-ip show \
    --name kthw \
    --resource-group ${RESOURCE_GROUP} \
    --query 'ipAddress' \
    --output tsv
)

echo "${KUBERNETES_PUBLIC_ADDRESS}"
