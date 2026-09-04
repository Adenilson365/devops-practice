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

data "aws_security_group" "selected" {
  id = "sg-06ecf3a754aac7d96"
}

output "security_group_id" {
  value = data.aws_security_group.selected.id
}

resource "aws_instance" "example" {
  ami           = "ami-081b0a6eac00b4f53"
  instance_type = "t2.micro"
  region = "us-east-1"
  security_groups = ["sg-06ecf3a754aac7d96"]
  key_name = "kp-linux-dev"
  subnet_id = "subnet-0bf52ddac8f94980e"

  provisioner "local-exec" {
    command = "echo ${self.private_ip} > private_ip.txt"
  }
  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("../kp-linux-dev.pem")
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y httpd",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
    ]
  }

  provisioner "file" {
    source      = "./index.html"
    destination = "/home/ec2-user/index.html"
  }

  provisioner "remote-exec" {
      inline = [
        "sudo mv /home/ec2-user/index.html /var/www/html/index.html",
        "sudo systemctl restart httpd",
      ]
    }
    provisioner "local-exec" {
    command = "echo ${self.public_ip} > private_ip.txt"
  }


  tags = {
    Name = "ec2"
    Managed-by = "Terraform"
  }

}

  resource "terraform_data" "index_html" {
    depends_on = [aws_instance.example]
    triggers_replace = filesha256("./index.html")
    

  connection {
    host        = aws_instance.example.public_ip
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("../kp-linux-dev.pem")
  }

    provisioner "file" {
      source      = "./index.html"
      destination = "/home/ec2-user/index.html"
    }

    provisioner "remote-exec" {
      inline = [
        "sudo mv /home/ec2-user/index.html /var/www/html/index.html",
        "sudo systemctl restart httpd",
      ]
    }

  }