
data "aws_security_group" "selected" {
  id = "sg-06ecf3a754aac7d96"
}

output "security_group_id" {
  value = data.aws_security_group.selected.id
}

resource "aws_instance" "ec2" {
  ami                    = "ami-081b0a6eac00b4f53"
  instance_type          = "t3.micro"
  region                 = "us-east-1"
  vpc_security_group_ids = [data.aws_security_group.selected.id]
  key_name               = "kp-linux-dev"
  subnet_id              = "subnet-0bf52ddac8f94980e"

  tags = {
    Name        = "ec2"
    Managed-by  = "Terraform"
    Environment = "Dev"
  }

}