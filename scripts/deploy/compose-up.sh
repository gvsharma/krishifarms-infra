#!/bin/bash
# Start KrishiFarms Docker stack with correct compose files for the environment.
set -euo pipefail

KRISHI_HOME="/opt/krishifarms"
ENVIRONMENT="${1:-prod}"

if [[ -f "${KRISHI_HOME}/config/host.env" ]]; then
  # shellcheck source=/dev/null
  source "${KRISHI_HOME}/config/host.env"
fi

COMPOSE_PROJECT="${COMPOSE_PROJECT_NAME:-krishifarms}"
COMPOSE_ARGS=(-p "${COMPOSE_PROJECT}" -f "${KRISHI_HOME}/app/docker-compose.yml")

case "${ENVIRONMENT}" in
  prod)
    COMPOSE_ARGS+=(-f "${KRISHI_HOME}/app/docker-compose.prod.yml")
    if [[ "${SHARED_EC2_WITH_GAMYA:-true}" == "true" ]]; then
      COMPOSE_ARGS+=(-f "${KRISHI_HOME}/app/docker-compose.shared-ec2.yml")
    else
      COMPOSE_ARGS+=(-f "${KRISHI_HOME}/app/docker-compose.dedicated-ec2.yml")
    fi
    ;;
  dev) COMPOSE_ARGS+=(-f "${KRISHI_HOME}/app/docker-compose.dev.yml") ;;
  qa)  COMPOSE_ARGS+=(-f "${KRISHI_HOME}/app/docker-compose.qa.yml") ;;
  *)   echo "Unknown environment: ${ENVIRONMENT}"; exit 1 ;;
esac

cd "${KRISHI_HOME}/app"
docker compose "${COMPOSE_ARGS[@]}" up -d
docker compose "${COMPOSE_ARGS[@]}" ps
