#!/bin/bash
# Obtain or renew Let's Encrypt certificate and enable HTTPS on host nginx.
set -euo pipefail

API_DOMAIN="${API_DOMAIN:-api.krishifarms.in}"
ADMIN_EMAIL="${ADMIN_EMAIL:-admin@krishifarms.in}"
KRISHI_HOME="/opt/krishifarms"

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

envsubst '${API_DOMAIN}' < "${KRISHI_HOME}/app/nginx/host-nginx.conf.template" \
  > /etc/nginx/conf.d/krishifarms.conf

nginx -t && systemctl reload nginx

echo "SSL configured for ${API_DOMAIN}"
