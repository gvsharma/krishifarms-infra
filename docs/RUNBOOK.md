# Operations Runbook

## Daily operations

| Task | Command |
|------|---------|
| SSM shell | `aws ssm start-session --target <instance-id>` |
| Stack status | `docker compose -f /opt/krishifarms/app/docker-compose.yml ps` |
| Logs (API) | `docker compose logs -f api` |
| Health | `/opt/krishifarms/scripts/health-check.sh` |

## Deploy

Triggered by GitHub Actions `Deploy Backend` workflow or manually:

```bash
/opt/krishifarms/scripts/deploy.sh <git-sha-or-tag>
```

## Backup

Automatic: cron daily 02:00 IST via `backup-db.sh`.

Manual:

```bash
BACKUP_BUCKET=krishifarms-prod-backups-ACCOUNT_ID \
  ENVIRONMENT=prod /opt/krishifarms/scripts/backup-db.sh daily
```

Restore:

```bash
aws s3 cp s3://BUCKET/postgres/daily/prod/FILE.dump.gz /tmp/
gunzip /tmp/FILE.dump.gz
docker compose exec -T postgres pg_restore -U krishi -d krishifarms --clean /tmp/FILE.dump
```

## SSL renewal

Certbot cron runs at 03:00 and 15:00 UTC. Manual:

```bash
sudo certbot renew --dry-run
```

## Monitoring

- CloudWatch dashboard: output `cloudwatch_dashboard` from Terraform
- Alarms: CPU > 85%, status check failed, backup metric missing

## Incident: API down

1. Check `docker compose ps`
2. Check host nginx: `sudo nginx -t && sudo systemctl status nginx`
3. Check disk: `df -h /opt/krishifarms/data`
4. Roll back: redeploy previous image tag via `deploy.sh`
