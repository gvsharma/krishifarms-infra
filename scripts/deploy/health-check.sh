#!/bin/bash
set -euo pipefail

URL="${1:-http://127.0.0.1:8080/health}"
curl -sf "${URL}" && echo " OK" || { echo " FAIL"; exit 1; }

docker compose -f /opt/krishifarms/app/docker-compose.yml ps
