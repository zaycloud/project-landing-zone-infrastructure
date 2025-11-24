variable "project_id" {
  description = "Vilket GCP-projekt ska vi bygga i?"
  type        = string
  default     = "zayn-lz" # vi fyller i detta automatiskt
}

variable "region" {
  description = "Vilket datacenter?"
  type        = string
  default     = "europe-north1"
}