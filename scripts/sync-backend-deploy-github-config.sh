#!/usr/bin/env bash
# Sync krishifarms-crm GitHub Actions variables/secrets from Terraform outputs.
set -euo pipefail

if [[ -z "${GH_TOKEN:-}" ]]; then
  echo "KRISHIFARMS_GH_TOKEN not configured — skipping auto-sync."
  exit 0
fi

REPO="${GITHUB_BACKEND_REPOSITORY:-gvsharma/krishifarms-crm}"
WORKING_DIR="${TF_WORKING_DIR:-environments/dev}"

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI not found." >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required." >&2
  exit 1
fi

cd "$(dirname "$0")/.."
cd "$WORKING_DIR"

SETUP="$(terraform output -json backend_deploy_github_setup)"
if [[ "$SETUP" == "null" ]]; then
  echo "backend_deploy_github_setup is null — set enable_backend_ssm_deploy = true and apply." >&2
  exit 1
fi

ROLE_ARN="$(echo "$SETUP" | jq -r '.secret_AWS_BACKEND_DEPLOY_ROLE_ARN')"
DEPLOY_BUCKET="$(echo "$SETUP" | jq -r '.variable_DEPLOY_BUCKET')"
EC2_INSTANCE_ID="$(echo "$SETUP" | jq -r '.variable_EC2_INSTANCE_ID')"
EC2_HOST="$(echo "$SETUP" | jq -r '.variable_EC2_HOST')"
HEALTH_CHECK_URL="$(echo "$SETUP" | jq -r '.variable_HEALTH_CHECK_URL')"
AWS_REGION="$(echo "$SETUP" | jq -r '.variable_AWS_REGION')"

echo "Syncing deploy config to ${REPO}..."
gh secret set AWS_BACKEND_DEPLOY_ROLE_ARN --repo "$REPO" --body "$ROLE_ARN"
gh variable set DEPLOY_BUCKET --repo "$REPO" --body "$DEPLOY_BUCKET"
gh variable set EC2_INSTANCE_ID --repo "$REPO" --body "$EC2_INSTANCE_ID"
gh variable set EC2_HOST --repo "$REPO" --body "$EC2_HOST"
gh variable set HEALTH_CHECK_URL --repo "$REPO" --body "$HEALTH_CHECK_URL"
gh variable set AWS_REGION --repo "$REPO" --body "$AWS_REGION"

echo "Done. EC2=${EC2_INSTANCE_ID} HOST=${EC2_HOST} BUCKET=${DEPLOY_BUCKET}"
