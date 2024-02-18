#! /usr/bin/env bash

set -euo pipefail

RESOURCE_GROUP="Kubernetes-The-Hard-Way"
KUBECONFIG_PATH=kubeconfig
TLS_PATH=tls

KUBERNETES_PUBLIC_ADDRESS=$(
  az network public-ip show \
    --name kthw \
    --resource-group ${RESOURCE_GROUP} \
    --query 'ipAddress' \
    --output tsv
)

kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=${TLS_PATH}/ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443

kubectl config set-credentials admin \
  --client-certificate=${TLS_PATH}/admin.pem \
  --client-key=${TLS_PATH}/admin-key.pem \

kubectl config set-context kubernetes-the-hard-way \
  --cluster=kubernetes-the-hard-way \
  --user=admin

kubectl config use-context kubernetes-the-hard-way
