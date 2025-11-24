variable "project_id" {}
variable "region" {}

resource "google_compute_network" "vpc" {
  name                    = "vpc"
  project                 = var.project_id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "private-subnet"
  project       = var.project_id
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.0.0.0/20"

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.1.0.0/16"
  }
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.2.0.0/20"
  }
}

# NAT, router, firewall
resource "google_compute_router" "router" {
  name    = "nat-router"
  project = var.project_id
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "nat"
  project                            = var.project_id
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_firewall" "deny_all" {
  name      = "deny-all-ingress"
  project   = var.project_id
  network   = google_compute_network.vpc.name
  direction = "INGRESS"
  priority  = 65534
  deny { protocol = "all" }
  source_ranges = ["0.0.0.0/0"]
}

# Outputs
output "network_name" { value = google_compute_network.vpc.name }
output "subnet_name" { value = google_compute_subnetwork.subnet.name }
output "pods_range_name" { value = "pods" }
output "services_range_name" { value = "services" }