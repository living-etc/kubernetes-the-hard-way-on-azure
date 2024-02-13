#!/usr/bin/env bash

set -euo pipefail

KEY="kubernetes-the-hard-way-on-azure/terraform.tfstate"

terraform init \
  -backend-config="bucket=${TERRAFORM_STATE_FILE_BUCKET}" \
  -backend-config="key=${KEY}" \
  "$@"
