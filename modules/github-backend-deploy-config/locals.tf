locals {
  repo_parts = split("/", var.repository)
  owner      = local.repo_parts[0]
  name       = local.repo_parts[1]
}
