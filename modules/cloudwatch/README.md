# CloudWatch — KrishiFarms CRM

Creates log groups for nginx, API, Docker, backup, and bootstrap scripts. Alarms for CPU, status checks, and backup success metric. Ops dashboard for EC2 metrics.

The CloudWatch agent on EC2 (installed by bootstrap) ships logs to these groups.
