#!/bin/bash
set -euo pipefail

API_DOMAIN="${API_DOMAIN:-api.krishifarms.in}"
ADMIN_EMAIL="${ADMIN_EMAIL:-admin@krishifarms.in}"
NGINX_UPSTREAM_PORT="${NGINX_UPSTREAM_PORT:-8081}"
KRISHI_HOME="/opt/krishifarms"

if [[ -f "${KRISHI_HOME}/config/host.env" ]]; then
  # shellcheck source=/dev/null
  source "${KRISHI_HOME}/config/host.env"
  NGINX_UPSTREAM_PORT="${NGINX_LOCAL_PORT:-8081}"
fi

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo API_DOMAIN=... ADMIN_EMAIL=... $0"
  exit 1
fi

certbot certonly --webroot \
  -w /var/www/certbot \
  -d "${API_DOMAIN}" \
  --email "${ADMIN_EMAIL}" \
  --agree-tos \
  --non-interactive \
  --keep-until-expiring

export API_DOMAIN NGINX_UPSTREAM_PORT
envsubst '${API_DOMAIN} ${NGINX_UPSTREAM_PORT}' \
  < "${KRISHI_HOME}/app/nginx/host-nginx.conf.template" \
  > /etc/nginx/conf.d/krishifarms.conf

nginx -t && systemctl reload nginx

echo "SSL configured for ${API_DOMAIN} → 127.0.0.1:${NGINX_UPSTREAM_PORT}"
