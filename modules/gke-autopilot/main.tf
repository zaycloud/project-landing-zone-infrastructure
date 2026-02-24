variable "project_id" {}
variable "region" {}
variable "network" {}
variable "subnet" {}
variable "pods_range" {}
variable "svc_range" {}
variable "environment" {}

resource "google_container_cluster" "primary" {
  name     = "portfolio-cluster" # Vi ger det ett snyggare namn än bara "cluster"
  project  = var.project_id
  location = var.region

  enable_autopilot = true

  network    = var.network
  subnetwork = var.subnet

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range
    services_secondary_range_name = var.svc_range
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  resource_labels = {
    environment = var.environment
  }

  deletion_protection = false
}

output "cluster_name" {
  value = google_container_cluster.primary.name
}