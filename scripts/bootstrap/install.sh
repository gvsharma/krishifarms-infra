#!/bin/bash
# EC2 bootstrap for KrishiFarms CRM.
# Shared EC2 (default): coexists with Gamya Couture at /opt/gamya-couture on port 8080.
# KrishiFarms uses port 8081 — host nginx routes by server_name, NOT default_server.
#
# Run as root:
#   SHARED_EC2=true API_DOMAIN=api.krishifarms.in bash install.sh
set -euxo pipefail

KRISHI_HOME="/opt/krishifarms"
ENVIRONMENT="${ENVIRONMENT:-prod}"
API_DOMAIN="${API_DOMAIN:-api.krishifarms.in}"
NGINX_LOCAL_PORT="${NGINX_LOCAL_PORT:-8081}"
AWS_REGION="${AWS_REGION:-ap-south-1}"
GAMYA_HOME="/opt/gamya-couture"

# Auto-detect shared mode if Gamya is already installed.
if [[ -d "${GAMYA_HOME}" ]]; then
  SHARED_EC2=true
fi
SHARED_EC2="${SHARED_EC2:-true}"

exec > >(tee /var/log/krishifarms-bootstrap.log | logger -t krishifarms-bootstrap -s 2>/dev/console) 2>&1

echo "=== KrishiFarms bootstrap: env=${ENVIRONMENT} shared=${SHARED_EC2} port=${NGINX_LOCAL_PORT} ==="

# --- Packages (skip if Gamya bootstrap already installed them) ---
PACKAGES=(docker docker-compose-plugin amazon-cloudwatch-agent awscli jq cronie certbot python3-certbot-nginx)
if [[ "${SHARED_EC2}" != "true" ]]; then
  PACKAGES+=(nginx)
fi

dnf update -y
dnf install -y "${PACKAGES[@]}"

systemctl enable --now docker
systemctl enable --now crond
usermod -aG docker ec2-user

if [[ "${SHARED_EC2}" != "true" ]]; then
  systemctl enable --now nginx
fi

# --- Directory layout (isolated from Gamya) ---
install -d -m 0755 "${KRISHI_HOME}"/{app,config,logs,data,scripts,releases}
install -d -m 0755 "${KRISHI_HOME}/logs"/{nginx,api,docker,backup}
install -d -m 0755 "${KRISHI_HOME}/data"/{postgres,redis}
install -d -m 0755 /var/www/certbot
chown -R ec2-user:ec2-user "${KRISHI_HOME}"

# --- Host env ---
cat >"${KRISHI_HOME}/config/host.env" <<HOSTENV
SHARED_EC2_WITH_GAMYA=${SHARED_EC2}
NGINX_LOCAL_PORT=${NGINX_LOCAL_PORT}
API_DOMAIN=${API_DOMAIN}
HEALTH_CHECK_URL=http://127.0.0.1:${NGINX_LOCAL_PORT}/health
COMPOSE_PROJECT_NAME=krishifarms
HOSTENV
chmod 640 "${KRISHI_HOME}/config/host.env"

# --- Copy docker assets ---
if [[ -d /tmp/krishifarms-infra/docker ]]; then
  cp -r /tmp/krishifarms-infra/docker/* "${KRISHI_HOME}/app/"
fi

# --- Scripts ---
declare -A SCRIPT_MAP=(
  [backup-db.sh]="backup/backup-db.sh"
  [setup-ssl.sh]="ssl/setup-ssl.sh"
  [deploy.sh]="deploy/deploy.sh"
  [health-check.sh]="deploy/health-check.sh"
  [compose-up.sh]="deploy/compose-up.sh"
)
for dest in "${!SCRIPT_MAP[@]}"; do
  src="/tmp/krishifarms-infra/scripts/${SCRIPT_MAP[$dest]}"
  if [[ -f "${src}" ]]; then
    cp "${src}" "${KRISHI_HOME}/scripts/${dest}"
    chmod 755 "${KRISHI_HOME}/scripts/${dest}"
  fi
done

# --- CloudWatch agent (KrishiFarms log paths only) ---
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent-krishifarms.json <<CW
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "${KRISHI_HOME}/logs/nginx/access.log",
            "log_group_name": "/krishifarms/${ENVIRONMENT}/nginx/access",
            "log_stream_name": "{instance_id}/access",
            "timezone": "UTC"
          },
          {
            "file_path": "${KRISHI_HOME}/logs/nginx/error.log",
            "log_group_name": "/krishifarms/${ENVIRONMENT}/nginx/error",
            "log_stream_name": "{instance_id}/error",
            "timezone": "UTC"
          },
          {
            "file_path": "${KRISHI_HOME}/logs/backup/backup.log",
            "log_group_name": "/krishifarms/${ENVIRONMENT}/backup",
            "log_stream_name": "{instance_id}/backup",
            "timezone": "UTC"
          }
        ]
      }
    }
  }
}
CW

# Merge with existing agent config if Gamya already configured CloudWatch.
if [[ -f /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json ]] && [[ "${SHARED_EC2}" == "true" ]]; then
  echo "CloudWatch agent already configured (Gamya). Add KrishiFarms log paths manually or merge JSON."
else
  cp /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent-krishifarms.json \
     /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
  /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
fi

# --- Host nginx: KrishiFarms vhost ONLY (never default_server on shared EC2) ---
cat > /etc/nginx/conf.d/krishifarms.conf <<NGINX
upstream krishifarms_docker_nginx {
    server 127.0.0.1:${NGINX_LOCAL_PORT};
}

server {
    listen 80;
    listen [::]:80;
    server_name ${API_DOMAIN};

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location /health {
        access_log off;
        proxy_pass http://krishifarms_docker_nginx;
    }

    location / {
        proxy_pass http://krishifarms_docker_nginx;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
NGINX

# Do NOT remove Gamya nginx config or default_server on shared EC2.
if [[ "${SHARED_EC2}" != "true" ]]; then
  rm -f /etc/nginx/conf.d/default.conf 2>/dev/null || true
fi

nginx -t && systemctl reload nginx

# --- Cron ---
echo "0 2 * * * root ${KRISHI_HOME}/scripts/backup-db.sh >> ${KRISHI_HOME}/logs/backup/cron.log 2>&1" \
  > /etc/cron.d/krishifarms-backup
echo "0 3,15 * * * root certbot renew --quiet --deploy-hook 'systemctl reload nginx'" \
  > /etc/cron.d/krishifarms-certbot

touch "${KRISHI_HOME}/logs/nginx/access.log" "${KRISHI_HOME}/logs/nginx/error.log"
touch "${KRISHI_HOME}/logs/backup/backup.log"
chown -R ec2-user:ec2-user "${KRISHI_HOME}/logs"

echo "=== Bootstrap complete (shared=${SHARED_EC2}, upstream=127.0.0.1:${NGINX_LOCAL_PORT}) ==="
echo "=== Gamya stays on :8080 | KrishiFarms on :${NGINX_LOCAL_PORT} | Route by server_name ==="
