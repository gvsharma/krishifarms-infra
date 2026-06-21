# S3 — KrishiFarms CRM

Creates four buckets per environment:

| Bucket | Purpose |
|--------|---------|
| `documents` | CRM document uploads (presigned URLs) |
| `backups` | PostgreSQL pg_dump archives |
| `frontend` | React static build artifacts |
| `deploy` | CI release bundles for SSM deploy |

All buckets: SSE-S3, public access blocked, versioning optional. Lifecycle rules expire old backups and deploy artifacts.
