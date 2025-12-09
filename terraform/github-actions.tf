module "github_actions" {
  source = "./modules/github-actions"

  project_id  = var.project_id
  github_org  = var.github_org
  github_repo = var.github_repo

  # Use existing workload identity resources
  pool_id     = var.workload_identity_pool_id
  provider_id = var.workload_identity_provider_id

  depends_on = [google_project_service.required_apis]
}
