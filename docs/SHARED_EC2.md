# Shared EC2 with Gamya Couture

KrishiFarms CRM and Gamya Couture run on the **same EC2** to avoid extra compute cost. They are isolated by **directory**, **Docker project name**, **local port**, and **nginx server_name**.

## Port map

| Application | Host path | Docker project | Local port | Public URL |
|-------------|-----------|----------------|------------|------------|
| Gamya Couture API | `/opt/gamya-couture/` | (existing) | **8080** | `api.gamyacouture.com` |
| KrishiFarms prod | `/opt/krishifarms/` | `krishifarms` | **8081** | `api.krishifarms.in` |
| KrishiFarms dev | `/opt/krishifarms/` | `krishifarms-dev` | **8082** | `dev.api.krishifarms.in` |
| KrishiFarms qa | `/opt/krishifarms/` | `krishifarms-qa` | **8083** | `qa.api.krishifarms.in` |

Host nginx routes by **domain** (`server_name`), not by `default_server`. Gamya keeps its existing default; KrishiFarms adds `/etc/nginx/conf.d/krishifarms.conf` only.

## Request flow

```
api.gamyacouture.com:443  →  host nginx  →  127.0.0.1:8080  →  Gamya Spring Boot
api.krishifarms.in:443    →  host nginx  →  127.0.0.1:8081  →  KrishiFarms Docker nginx → FastAPI
```

## Install KrishiFarms on existing Gamya EC2

### 1. Terraform (same instance ID as Gamya)

In `environments/prod/terraform.tfvars`:

```hcl
existing_ec2_instance_id = "i-XXXXXXXXX"   # same Gamya EC2
existing_ec2_public_ip   = "x.x.x.x"       # same Elastic IP
vpc_id                   = "vpc-XXXXXXXXX"
```

Apply KrishiFarms Terraform — it creates **separate S3 buckets, IAM policies, DNS records**. It does **not** create a new EC2.

### 2. Merge IAM instance profile

The EC2 can have **one** instance profile. Attach policies for **both** apps:

| Policy source | Allows |
|---------------|--------|
| Gamya EC2 role | Gamya S3, RDS secrets |
| KrishiFarms EC2 role | KrishiFarms S3 documents + backups |

**Option A — attach both policy ARNs to one role** (recommended):

```bash
# After krishifarms terraform apply
KRISHI_PROFILE=$(terraform -chdir=environments/prod output -raw ec2_instance_profile_name)
aws iam list-attached-role-policies --role-name "${KRISHI_PROFILE#*/}" 
# Or attach Krishi inline policies to existing Gamya role manually in IAM console
```

**Option B — add Gamya bucket ARNs to KrishiFarms IAM module** (if Gamya needs Krishi role — usually keep Gamya role and add Krishi S3 statements to it).

### 3. Bootstrap KrishiFarms (does not touch Gamya)

```bash
aws ssm start-session --target i-XXXXXXXXX

# Copy infra repo to /tmp, then:
sudo SHARED_EC2=true API_DOMAIN=api.krishifarms.in NGINX_LOCAL_PORT=8081 \
  bash /tmp/krishifarms-infra/scripts/bootstrap/install.sh
```

Bootstrap will:

- Detect `/opt/gamya-couture` and enable shared mode
- **Not** overwrite Gamya nginx `default_server`
- Install KrishiFarms under `/opt/krishifarms/` only
- Bind Docker nginx to **8081**

### 4. SSL for KrishiFarms domain

```bash
sudo API_DOMAIN=api.krishifarms.in ADMIN_EMAIL=you@domain.com \
  bash /opt/krishifarms/scripts/ssl/setup-ssl.sh
```

### 5. Start KrishiFarms stack

```bash
# Configure secrets
sudo cp /path/to/.env /opt/krishifarms/config/.env
sudo chmod 600 /opt/krishifarms/config/.env

/opt/krishifarms/scripts/compose-up.sh prod
/opt/krishifarms/scripts/health-check.sh
```

### 6. Verify both apps

```bash
curl -s http://127.0.0.1:8080/health    # Gamya
curl -s http://127.0.0.1:8081/health    # KrishiFarms
curl -sI https://api.gamyacouture.com/health
curl -sI https://api.krishifarms.in/health
```

## What stays separate

| Resource | Gamya | KrishiFarms |
|----------|-------|-------------|
| Database | RDS PostgreSQL | Docker PostgreSQL (`/opt/krishifarms/data/postgres`) |
| Redis | (if any) | Docker Redis |
| S3 buckets | `gamya-couture-*` | `krishifarms-prod-*` |
| Backups | RDS / Gamya scripts | `backup-db.sh` → Krishi S3 |
| Deploy | Gamya CI | Krishi `deploy.sh` via SSM |
| Logs | `/opt/gamya-couture/logs` | `/opt/krishifarms/logs` |

## Resource limits (shared `t4g.small` / `t4g.medium`)

Prod compose caps KrishiFarms memory when sharing:

- PostgreSQL: 1.5 GB max
- FastAPI: 768 MB max

Monitor with `docker stats` and `htop`. If the host is tight, stop KrishiFarms dev/qa stacks on the same machine.

## Terraform ownership

| Repo | Manages on shared EC2 |
|------|------------------------|
| `gamya-couture-infra` | Original EC2, Gamya SG (optional), Gamya IAM |
| `krishifarms-infra` | **Data source only** for EC2; S3, IAM profile (attach manually), Route53 `api.krishifarms.in`, CloudWatch log groups |

Do **not** run Gamya Terraform changes that replace user-data or recreate the instance after KrishiFarms is installed.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Krishi 502, Gamya works | `docker compose -p krishifarms ps`; check `:8081` |
| Gamya 502 after Krishi install | Krishi bootstrap used `default_server` — remove from `krishifarms.conf`, reload nginx |
| Wrong app on domain | Check `server_name` in both nginx conf files |
| Port in use | `ss -tlnp \| grep 808` — Gamya=8080, Krishi=8081 |
| Out of disk | Postgres data in `/opt/krishifarms/data` — expand EBS or prune Docker |

## If you later split to dedicated EC2

1. Launch or assign a new instance
2. Update `existing_ec2_instance_id` in Terraform
3. Set `SHARED_EC2_WITH_GAMYA=false` in `/opt/krishifarms/config/host.env`
4. Use `docker-compose.dedicated-ec2.yml` (port 8080)
5. Remove `/etc/nginx/conf.d/krishifarms.conf` from Gamya host
