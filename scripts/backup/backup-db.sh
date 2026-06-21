#!/bin/bash
# PostgreSQL logical backup to S3 with CloudWatch success metric.
set -euo pipefail

KRISHI_HOME="/opt/krishifarms"
ENVIRONMENT="${ENVIRONMENT:-prod}"
AWS_REGION="${AWS_REGION:-ap-south-1}"
BACKUP_BUCKET="${BACKUP_BUCKET:?set BACKUP_BUCKET e.g. krishifarms-prod-backups-123456789012}"
COMPOSE_FILE="${KRISHI_HOME}/app/docker-compose.yml"
COMPOSE_OVERRIDE="${KRISHI_HOME}/app/docker-compose.${ENVIRONMENT}.yml"
LOG_FILE="${KRISHI_HOME}/logs/backup/backup.log"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
BACKUP_TYPE="${1:-daily}"
DUMP_FILE="/tmp/krishifarms-${ENVIRONMENT}-${TIMESTAMP}.dump.gz"

log() { echo "[$(date -Is)] $*" | tee -a "${LOG_FILE}"; }

cleanup() {
  rm -f "${DUMP_FILE}"
}
trap cleanup EXIT

log "Starting ${BACKUP_TYPE} backup"

cd "${KRISHI_HOME}/app"
COMPOSE_ARGS=(-f "${COMPOSE_FILE}")
[[ -f "${COMPOSE_OVERRIDE}" ]] && COMPOSE_ARGS+=(-f "${COMPOSE_OVERRIDE}")

docker compose "${COMPOSE_ARGS[@]}" exec -T postgres \
  pg_dump -U "${POSTGRES_USER:-krishi}" -Fc "${POSTGRES_DB:-krishifarms}" \
  | gzip > "${DUMP_FILE}"

S3_KEY="postgres/${BACKUP_TYPE}/${ENVIRONMENT}/krishifarms-${TIMESTAMP}.dump.gz"
aws s3 cp "${DUMP_FILE}" "s3://${BACKUP_BUCKET}/${S3_KEY}" --region "${AWS_REGION}"

log "Uploaded s3://${BACKUP_BUCKET}/${S3_KEY}"

aws cloudwatch put-metric-data \
  --region "${AWS_REGION}" \
  --namespace "KrishiFarms/Backup" \
  --metric-data "[{
    \"MetricName\": \"BackupSuccess\",
    \"Value\": 1,
    \"Unit\": \"Count\",
    \"Dimensions\": [{\"Name\": \"Environment\", \"Value\": \"${ENVIRONMENT}\"}]
  }]"

log "Backup complete"
