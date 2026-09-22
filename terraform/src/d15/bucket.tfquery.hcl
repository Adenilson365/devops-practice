list "aws_s3_bucket" "s3-dev" {
  provider = aws
  
}

list "aws_instance" "ec2-dev" {
  provider = aws

  config {
    filter {
      name   = "instance-state-name"
      values = ["running"]
    }
  }
}
