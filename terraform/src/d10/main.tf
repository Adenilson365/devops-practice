
data "aws_instance" "out" {
  instance_id = "i-04d76bfda799955b7"
}

output "instance_public_ip" {
  value = data.aws_instance.out.public_ip
}

resource "aws_instance" "import" {
  ami           = "ami-0354c98ae10b02961"
  instance_type = "t2.micro"
  region        = "us-east-1"

  subnet_id = "subnet-0fd0c237b3e70c7d7"

  vpc_security_group_ids = [
    "sg-06ecf3a754aac7d96"
  ]

  key_name = "kp-linux-dev"

  tags = {
    Name      = "out"
    ManagedBy = "Terraform"
    Imported  = "true"
  }
}

import {
  to = aws_instance.import
  id = "i-04d76bfda799955b7"
}