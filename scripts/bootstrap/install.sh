#!/bin/bash
# EC2 first-run bootstrap for KrishiFarms CRM.
# Run as root: sudo bash install.sh
set -euxo pipefail

KRISHI_HOME="/opt/krishifarms"
ENVIRONMENT="${ENVIRONMENT:-prod}"
API_DOMAIN="${API_DOMAIN:-api.krishifarms.in}"
AWS_REGION="${AWS_REGION:-ap-south-1}"

exec > >(tee /var/log/krishifarms-bootstrap.log | logger -t krishifarms-bootstrap -s 2>/dev/console) 2>&1

echo "=== KrishiFarms bootstrap: env=${ENVIRONMENT} domain=${API_DOMAIN} ==="

# --- Packages ---
dnf update -y
dnf install -y \
  docker \
  docker-compose-plugin \
  nginx \
  certbot \
  python3-certbot-nginx \
  amazon-cloudwatch-agent \
  awscli \
  jq \
  cronie

systemctl enable --now docker
systemctl enable --now crond
usermod -aG docker ec2-user

# --- Directory layout ---
install -d -m 0755 "${KRISHI_HOME}"/{app,config,logs,data,scripts,releases}
install -d -m 0755 "${KRISHI_HOME}/logs"/{nginx,api,docker,backup}
install -d -m 0755 "${KRISHI_HOME}/data"/{postgres,redis}
install -d -m 0755 /var/www/certbot
chown -R ec2-user:ec2-user "${KRISHI_HOME}"

# --- Copy docker assets (if repo cloned to /tmp during bootstrap) ---
if [[ -d /tmp/krishifarms-infra/docker ]]; then
  cp -r /tmp/krishifarms-infra/docker/* "${KRISHI_HOME}/app/"
fi

# --- Scripts ---
declare -A SCRIPT_MAP=(
  [backup-db.sh]="backup/backup-db.sh"
  [setup-ssl.sh]="ssl/setup-ssl.sh"
  [deploy.sh]="deploy/deploy.sh"
  [health-check.sh]="deploy/health-check.sh"
)
for dest in "${!SCRIPT_MAP[@]}"; do
  src="/tmp/krishifarms-infra/scripts/${SCRIPT_MAP[$dest]}"
  if [[ -f "${src}" ]]; then
    cp "${src}" "${KRISHI_HOME}/scripts/${dest}"
    chmod 755 "${KRISHI_HOME}/scripts/${dest}"
  fi
done

# --- CloudWatch agent config ---
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<CW
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
            "file_path": "${KRISHI_HOME}/logs/docker/containers.log",
            "log_group_name": "/krishifarms/${ENVIRONMENT}/docker",
            "log_stream_name": "{instance_id}/docker",
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
  },
  "metrics": {
    "namespace": "KrishiFarms/EC2",
    "metrics_collected": {
      "disk": {
        "measurement": ["used_percent"],
        "metrics_collection_interval": 300,
        "resources": ["/", "/opt/krishifarms/data"]
      },
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 300
      }
    }
  }
}
CW

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

# --- Host nginx HTTP placeholder (SSL via setup-ssl.sh) ---
cat > /etc/nginx/conf.d/krishifarms.conf <<NGINX
upstream krishifarms_docker_nginx {
    server 127.0.0.1:8080;
}

server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name ${API_DOMAIN} _;

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

rm -f /etc/nginx/conf.d/default.conf 2>/dev/null || true
nginx -t && systemctl enable --now nginx

# --- Cron: daily backup 02:00 IST ---
echo "0 2 * * * root ${KRISHI_HOME}/scripts/backup-db.sh >> ${KRISHI_HOME}/logs/backup/cron.log 2>&1" \
  > /etc/cron.d/krishifarms-backup

# --- Cron: certbot renew twice daily ---
echo "0 3,15 * * * root certbot renew --quiet --deploy-hook 'systemctl reload nginx'" \
  > /etc/cron.d/krishifarms-certbot

touch "${KRISHI_HOME}/logs/nginx/access.log" "${KRISHI_HOME}/logs/nginx/error.log"
touch "${KRISHI_HOME}/logs/docker/containers.log" "${KRISHI_HOME}/logs/backup/backup.log"
chown -R ec2-user:ec2-user "${KRISHI_HOME}/logs"

echo "=== Bootstrap complete. Next: setup-ssl.sh, configure .env, docker compose up -d ==="
