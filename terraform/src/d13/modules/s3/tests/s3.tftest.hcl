mock_provider "aws" {}

run "dev_bucket_name" {
  command = plan

  variables {
    project     = "payment"
    environment = "dev"

  }
  assert {
    condition     = aws_s3_bucket.this.bucket == "payment-dev"
    error_message = "Bucket name should be payment-dev"
  }
}


run "required_tags" {

    command = plan

    variables {
      project     = "payment"
      environment = "dev"
    }

    assert {
        condition = aws_s3_bucket.this.tags["Project"] == "payment" && aws_s3_bucket.this.tags["Environment"] == "dev"
        error_message = "Tags should be set correctly"
    }

    assert {
        condition = aws_s3_bucket.this.tags["ManagedBy"] == "Terraform"
        error_message = "ManagedBy tag should be set to Terraform"
    }

}

run "production_requires_versioning" {

  command = plan

  variables {

    project     = "payment"
    environment = "prod"

  }

  assert {

    condition = (
      aws_s3_bucket_versioning.this
      .versioning_configuration[0]
      .status == "Enabled"
    )

    error_message = "Production buckets must have versioning enabled."

  }

}


run "development_versioning" {

  command = plan

  variables {

    project     = "payment"
    environment = "dev"

  }

  assert {

    condition = (
      aws_s3_bucket_versioning.this
      .versioning_configuration[0]
      .status == "Suspended"
    )

    error_message = "Development bucket should not have versioning enabled."

  }

}

run "public_access_is_blocked" {

  command = plan

  variables {

    project     = "payment"
    environment = "prod"

  }

  assert {

    condition = (
      aws_s3_bucket_public_access_block.this.block_public_acls
      &&
      aws_s3_bucket_public_access_block.this.block_public_policy
      &&
      aws_s3_bucket_public_access_block.this.ignore_public_acls
      &&
      aws_s3_bucket_public_access_block.this.restrict_public_buckets
    )

    error_message = "S3 public access must be completely blocked."

  }

}

run "invalid_environment" {

  command = plan

  variables {

    project     = "payment"
    environment = "banana"

  }

  expect_failures = [
    var.environment
  ]

}