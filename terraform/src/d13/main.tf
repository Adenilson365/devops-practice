

module "s3" {
  source = "./modules/s3"

  project     = "payment"
  environment = "dev"
}

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.63.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
