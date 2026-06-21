# Security Groups — KrishiFarms CRM

EC2-only security group. PostgreSQL and Redis run inside Docker and are **not** exposed via SG rules.

Attach this security group to your existing EC2 instance (in addition to or replacing current SGs).
