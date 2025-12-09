variable "project_id" {
  type        = string
  description = "GCP project id"
  default     = "lily-demo-ml"
}

variable "project_number" {
  type        = string
  description = "GCP project number (used for service account members)"
  default     = "167672209455"
}

variable "region" {
  type        = string
  description = "GCP region"
  default     = "us-central1"
}

variable "user_emails" {
  description = "List of user emails for IAM permissions (loaded from users.yaml)"
  type        = list(string)
  default     = []
}

variable "github_org" {
  description = "GitHub organization or username"
  type        = string
  default     = "lilyle-2211"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "inference-template"
}

variable "artifact_repo_id" {
  type        = string
  description = "Artifact Registry repository id (DOCKER)"
  default     = "inference-template"
}

variable "storage_bucket_name" {
  type        = string
  description = "Suffix for GCS bucket; final bucket name will be <project_id>-<storage_bucket_name>"
  default     = "inference-template-bucket"
}

# ==========================================================================
# GKE Variables
# ==========================================================================

variable "gke_cluster_name" {
  type        = string
  description = "GKE cluster name"
  default     = "inference-template-cluster"
}

variable "gke_cluster_location" {
  type        = string
  description = "Location for the GKE cluster (region or zone depending on resource)"
  default     = "us-central1"
}

variable "gke_zone" {
  type        = string
  description = "Zone for node pools"
  default     = "us-central1-a"
}

variable "gke_node_pool_name" {
  type        = string
  description = "GKE node pool name"
  default     = "ml-node-pool"
}

variable "gke_initial_node_count" {
  type    = number
  default = 1
}

variable "gke_min_nodes" {
  type    = number
  default = 1
}

variable "gke_max_nodes" {
  type    = number
  default = 3
}

variable "gke_machine_type" {
  type    = string
  default = "e2-medium"
}

variable "gke_enable_autopilot" {
  type    = bool
  default = false
}

variable "inference_sa_account_id" {
  type        = string
  description = "Service account id for inference workloads"
  default     = "inference-template"
}

variable "models_bucket_name" {
  type        = string
  description = "Name of the GCS bucket used for models"
  default     = "lily-ml-models-20251205"
}

variable "k8s_namespace" {
  type    = string
  default = "default"
}

variable "k8s_service_account" {
  type    = string
  default = "inference-template-sa"
}

variable "workload_identity_pool_id" {
  type        = string
  description = "Existing Workload Identity Pool id"
  default     = "inference-template"
}

variable "workload_identity_provider_id" {
  type        = string
  description = "Existing Workload Identity Provider id (<=32 chars)"
  default     = "inference-template"
}
