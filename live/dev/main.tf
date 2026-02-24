terraform {
  required_version = ">= 1.14.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# 1. API:er
resource "google_project_service" "apis" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ])
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

# 2. Nätverket
module "network" {
  source     = "../../modules/network"
  project_id = var.project_id
  region     = var.region
  depends_on = [google_project_service.apis]
}

# 3. GKE Autopilot
module "gke" {
  # VIKTIGT: Se till att mappen heter exakt så här:
  source = "../../modules/gke-autopilot"

  project_id = var.project_id
  region     = var.region

  # Variablerna matchar nu din modul!
  network     = module.network.network_name
  subnet      = module.network.subnet_name
  pods_range  = module.network.pods_range_name
  svc_range   = module.network.services_range_name
  environment = "dev"

  depends_on = [module.network]
}

# 4. Koppla kubectl (Dynamiskt namn!)
output "connect" {
  value = "gcloud container clusters get-credentials ${module.gke.cluster_name} --region ${var.region} --project ${var.project_id}"
}