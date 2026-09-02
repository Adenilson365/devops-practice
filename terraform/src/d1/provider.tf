terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = ">= 2.7.0, <= 2.9.0"
    }
  }
}

provider "local" {
  # Configuration options
}