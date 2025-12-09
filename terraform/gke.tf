# GKE Cluster (Standard Mode)
resource "google_container_cluster" "inference_template_cluster" {
  project               = var.project_id
  name                  = var.gke_cluster_name
  location              = var.gke_cluster_location
  remove_default_node_pool = true
  initial_node_count    = 1
  deletion_protection = false

  # Workload Identity for pod authentication to GCP services
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Network configuration
  network    = "default"
  subnetwork = "default"

  depends_on = [google_project_service.required_apis]
}

# Node Pool for standard mode
resource "google_container_node_pool" "inference_template_nodes" {
  count = var.gke_enable_autopilot ? 0 : 1
  name     = var.gke_node_pool_name
  location = var.gke_zone
  cluster  = google_container_cluster.inference_template_cluster.name

  initial_node_count = var.gke_initial_node_count

  autoscaling {
    min_node_count = var.gke_min_nodes
    max_node_count = var.gke_max_nodes
  }

  node_config {
    machine_type = var.gke_machine_type
    disk_size_gb = 50

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    # Enable Workload Identity on nodes
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

# Service Account for inference workload
resource "google_service_account" "inference_sa" {
  account_id   = var.inference_sa_account_id
  display_name = "Inference Template Service Account"
  description  = "Service account for inference template pods to access GCS"

  depends_on = [google_project_service.required_apis]
}

# Grant GCS read permissions to inference service account
resource "google_storage_bucket_iam_member" "inference_sa_gcs_read" {
  bucket = var.models_bucket_name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.inference_sa.email}"
}

# Workload Identity binding: GCP SA <-> Kubernetes SA
resource "google_service_account_iam_member" "inference_workload_identity" {
  service_account_id = google_service_account.inference_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.k8s_namespace}/${var.k8s_service_account}]"
}
