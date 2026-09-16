## Import Using datasource
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

# Import com terraform plan -generate-config-out=import.tf

import {
  to = aws_instance.import1
  id = "i-0c028363598d126d8"
}


resource "aws_instance" "import1" {
  ami = "ami-0354c98ae10b02961"
  instance_type     = "t2.micro"
  key_name          = "kp-linux-dev"
  availability_zone = "us-east-1d"
  subnet_id         = "subnet-0fd0c237b3e70c7d7"
  tags = {
    Name = "out1"
  }
  vpc_security_group_ids = ["sg-06ecf3a754aac7d96"]
}
