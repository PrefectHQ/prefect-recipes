terraform {
  required_version = ">= 0.13"

  required_providers {
    aws        = ">= 3.4.0"
    kubernetes = ">= 2.3.1"
    helm       = ">= 2.4.1"
  }
}