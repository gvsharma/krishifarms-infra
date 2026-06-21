#!/bin/bash
set -euo pipefail

KRISHI_HOME="/opt/krishifarms"
HEALTH_CHECK_URL="${1:-}"

if [[ -z "${HEALTH_CHECK_URL}" && -f "${KRISHI_HOME}/config/host.env" ]]; then
  # shellcheck source=/dev/null
  source "${KRISHI_HOME}/config/host.env"
fi

HEALTH_CHECK_URL="${HEALTH_CHECK_URL:-http://127.0.0.1:8081/health}"

curl -sf "${HEALTH_CHECK_URL}" && echo " OK" || { echo " FAIL (${HEALTH_CHECK_URL})"; exit 1; }

COMPOSE_PROJECT="${COMPOSE_PROJECT_NAME:-krishifarms}"
docker compose -p "${COMPOSE_PROJECT}" -f "${KRISHI_HOME}/app/docker-compose.yml" ps
