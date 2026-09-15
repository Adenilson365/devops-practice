
data "aws_security_group" "selected" {
  id = "sg-06ecf3a754aac7d96"
}

output "security_group_id" {
  value = data.aws_security_group.selected.id
}

resource "aws_instance" "ec2" {
  ami             = "ami-081b0a6eac00b4f53"
  instance_type   = "t2.nano"
  region          = "us-east-1"
  vpc_security_group_ids = [data.aws_security_group.selected.id]
  key_name        = "win-kp"
  subnet_id       = "subnet-0bf52ddac8f94980e"

  tags = {
    Name       = "ec2"
    Managed-by = "Terraform"
    Environment = "Dev"
  }
  lifecycle {
    ignore_changes = [tags]
  }

}

resource "aws_instance" "ec3" {
  ami             = "ami-081b0a6eac00b4f53"
  instance_type   = "t2.micro"
  region          = var.region
  vpc_security_group_ids = [data.aws_security_group.selected.id]
  key_name        = "win-kp"
  subnet_id       = "subnet-0bf52ddac8f94980e"

  tags = {
    Name       = "ec3"
    Managed-by = "Terraform"
    Environment = "Dev"
  }
  lifecycle {
   precondition {
     condition = var.region == "us-east-1"
     error_message = "A região deve ser us-east-1 para criar a instância ec2"
   }
  }

}

resource "aws_instance" "ec4" {
  ami             = "ami-081b0a6eac00b4f53"
  instance_type   = "t2.micro"
  region          = var.region
  vpc_security_group_ids = [data.aws_security_group.selected.id]
  key_name        = "win-kp"
  subnet_id       = "subnet-0bf52ddac8f94980e"

  tags = {
    Name       = "ec4"
    Managed-by = "Terraform"
    Environment = "Dev"
  }
  lifecycle {
    replace_triggered_by = [aws_instance.ec2.id, aws_instance.ec3.id]
  }

}

# resource "aws_instance" "ec5" {
#   ami             = "ami-081b0a6eac00b4f53"
#   instance_type   = "t2.micro"
#   region          = var.region
#   vpc_security_group_ids = [data.aws_security_group.selected.id]
#   key_name        = "win-kp"
#   subnet_id       = "subnet-0bf52ddac8f94980e"

#   tags = {
#     Name       = "ec5"
#     Managed-by = "Terraform"
#     Environment = "Dev"
#   }

# }

removed {
  from = aws_instance.ec5
  lifecycle {
    destroy = false
  }
}

variable "region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "us-east-1"
}