#!/bin/bash
# Deploy new API image via Docker Compose. Invoked by GitHub Actions SSM or manually.
set -euo pipefail

KRISHI_HOME="/opt/krishifarms"
ENVIRONMENT="${ENVIRONMENT:-prod}"
IMAGE_TAG="${1:?usage: deploy.sh <image-tag>}"
API_IMAGE="${API_IMAGE:-ghcr.io/gvsharma/krishifarms-crm:${IMAGE_TAG}}"

COMPOSE_FILE="${KRISHI_HOME}/app/docker-compose.yml"
COMPOSE_OVERRIDE="${KRISHI_HOME}/app/docker-compose.${ENVIRONMENT}.yml"
COMPOSE_ARGS=(-f "${COMPOSE_FILE}")
[[ -f "${COMPOSE_OVERRIDE}" ]] && COMPOSE_ARGS+=(-f "${COMPOSE_OVERRIDE}")

cd "${KRISHI_HOME}/app"

echo "Pre-deploy backup..."
ENVIRONMENT="${ENVIRONMENT}" BACKUP_BUCKET="${BACKUP_BUCKET}" \
  "${KRISHI_HOME}/scripts/backup-db.sh" pre-deploy || true

export API_IMAGE
docker compose "${COMPOSE_ARGS[@]}" pull api
docker compose "${COMPOSE_ARGS[@]}" up -d --no-deps api

echo "Running migrations..."
docker compose "${COMPOSE_ARGS[@]}" exec -T api alembic upgrade head

echo "Health check..."
for i in {1..30}; do
  if curl -sf "http://127.0.0.1:8080/health" >/dev/null; then
    echo "Deploy successful: ${API_IMAGE}"
    exit 0
  fi
  sleep 2
done

echo "Health check failed — rolling back"
docker compose "${COMPOSE_ARGS[@]}" rollback api 2>/dev/null || true
exit 1
