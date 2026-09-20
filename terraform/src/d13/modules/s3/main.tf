terraform {

  required_version = ">= 1.7.0"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

  }

}

resource "aws_s3_bucket" "this" {

  bucket = "${var.project}-${var.environment}"

  tags = {
    Name        = "${var.project}-${var.environment}"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }

}

resource "aws_s3_bucket_versioning" "this" {

  bucket = aws_s3_bucket.this.id

  versioning_configuration {

    status = var.environment == "prod" ? "Enabled" : "Suspended"

  }

}

resource "aws_s3_bucket_public_access_block" "this" {

  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}