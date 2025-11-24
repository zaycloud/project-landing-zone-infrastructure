terraform {
  backend "gcs" {
    prefix = "landing-zone/dev"
  }
}