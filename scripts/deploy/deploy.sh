#!/bin/bash
set -euo pipefail

KRISHI_HOME="/opt/krishifarms"
ENVIRONMENT="${ENVIRONMENT:-prod}"
IMAGE_TAG="${1:?usage: deploy.sh <image-tag>}"
API_IMAGE="${API_IMAGE:-ghcr.io/gvsharma/krishifarms-crm:${IMAGE_TAG}}"
HEALTH_CHECK_URL="${HEALTH_CHECK_URL:-http://127.0.0.1:8081/health}"

if [[ -f "${KRISHI_HOME}/config/host.env" ]]; then
  # shellcheck source=/dev/null
  source "${KRISHI_HOME}/config/host.env"
fi

COMPOSE_PROJECT="${COMPOSE_PROJECT_NAME:-krishifarms}"
COMPOSE_ARGS=(-p "${COMPOSE_PROJECT}" -f "${KRISHI_HOME}/app/docker-compose.yml" -f "${KRISHI_HOME}/app/docker-compose.${ENVIRONMENT}.yml")

if [[ "${ENVIRONMENT}" == "prod" && "${SHARED_EC2_WITH_GAMYA:-true}" == "true" ]]; then
  COMPOSE_ARGS+=(-f "${KRISHI_HOME}/app/docker-compose.shared-ec2.yml")
elif [[ "${ENVIRONMENT}" == "prod" ]]; then
  COMPOSE_ARGS+=(-f "${KRISHI_HOME}/app/docker-compose.dedicated-ec2.yml")
fi

cd "${KRISHI_HOME}/app"

echo "Pre-deploy backup..."
ENVIRONMENT="${ENVIRONMENT}" BACKUP_BUCKET="${BACKUP_BUCKET}" \
  "${KRISHI_HOME}/scripts/backup-db.sh" pre-deploy || true

export API_IMAGE
docker compose "${COMPOSE_ARGS[@]}" pull api
docker compose "${COMPOSE_ARGS[@]}" up -d --no-deps api

echo "Running migrations..."
docker compose "${COMPOSE_ARGS[@]}" exec -T api alembic upgrade head

echo "Health check ${HEALTH_CHECK_URL}..."
for i in {1..30}; do
  if curl -sf "${HEALTH_CHECK_URL}" >/dev/null; then
    echo "Deploy successful: ${API_IMAGE}"
    exit 0
  fi
  sleep 2
done

echo "Health check failed — rolling back"
docker compose "${COMPOSE_ARGS[@]}" rollback api 2>/dev/null || true
exit 1
