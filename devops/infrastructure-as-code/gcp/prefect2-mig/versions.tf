terraform {
  required_version = "~> 1"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.44.1"
    }
  }
}
provider "google" {
  project = var.project_id
  region  = var.region
}
