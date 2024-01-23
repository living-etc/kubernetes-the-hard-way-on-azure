#! /usr/bin/env bash
set -exuo pipefail

RESOURCE_GROUP="Kubernetes-The-Hard-Way"
TLS_PATH=tls

KUBERNETES_PUBLIC_ADDRESS=$(
  az network public-ip list \
    --resource-group ${RESOURCE_GROUP} \
    --query "[].ipAddress" \
    --output tsv | tr '\n' ',' | sed 's/,$//'
)

KUBERNETES_PRIVATE_ADDRESS=$(
  az network nic list \
    --resource-group ${RESOURCE_GROUP} \
    --query '[].ipConfigurations[0].privateIPAddress' \
    --output tsv | tr '\n' ',' | sed 's/,$//'
)

KUBERNETES_HOSTNAMES=kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local

cfssl gencert \
  -ca=${TLS_PATH}/ca.pem \
  -ca-key=${TLS_PATH}/ca-key.pem \
  -config=${TLS_PATH}/ca-config.json \
  -hostname=10.32.0.1,${KUBERNETES_PRIVATE_ADDRESS},${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,${KUBERNETES_HOSTNAMES} \
  -profile=kubernetes \
  ${TLS_PATH}/kubernetes-csr.json | cfssljson -bare ${TLS_PATH}/kubernetes
