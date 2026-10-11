data "http" "local_ip" {
  url = "https://checkip.amazonaws.com/"
}

locals {
  local_ip = "${chomp(data.http.local_ip.response_body)}/32"
}

output "local_ip" {
  value = local.local_ip
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  region     = "us-east-1"
  tags = {
    Name = "drs-vpc"
    ManagedBy = "Terraform"
  }

}

resource "aws_subnet" "staging" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, 1)
  availability_zone = "us-east-1a"
  tags = {
    Name = "drs-staging-subnet"
    ManagedBy = "Terraform"
  }
}

resource "aws_subnet" "production" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, 2)
  availability_zone = "us-east-1b"
  tags = {
    Name = "drs-production-subnet"
    ManagedBy = "Terraform"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "drs-igw"
    ManagedBy = "Terraform"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "drs-route-table"
    ManagedBy = "Terraform"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.main.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "staging" {
  subnet_id      = aws_subnet.staging.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "production" {
  subnet_id      = aws_subnet.production.id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "staging" {
  name        = "drs-security-group-staging"
  description = "Security group for DRS application"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "drs-security-group-staging"
    ManagedBy = "Terraform"
  }

}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.staging.id
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
  description = "Allow all outbound traffic"
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.staging.id
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  to_port     = 443
  from_port   = 443
  description = "Allow HTTPS traffic"
}

resource "aws_vpc_security_group_ingress_rule" "allow_drs" {
  security_group_id = aws_security_group.staging.id
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  to_port     = 1500
  from_port   = 1500
  description = "Allow DRS data-plane traffic"
}


resource "aws_security_group" "production" {
  name        = "drs-security-group-production"
  description = "Security group for DRS application"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "drs-security-group-production"
    ManagedBy = "Terraform"
  }

}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound_production" {
  security_group_id = aws_security_group.production.id
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
  description = "Allow all outbound traffic"
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_production" {
  security_group_id = aws_security_group.production.id
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  to_port     = 443
  from_port   = 443
  description = "Allow HTTPS traffic"
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_production" {
  security_group_id = aws_security_group.production.id
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  to_port     = 80
  from_port   = 80
  description = "Allow HTTP traffic"
}



resource "aws_vpc_security_group_ingress_rule" "allow_ssh_production" {
  security_group_id = aws_security_group.production.id
  cidr_ipv4   = local.local_ip
  ip_protocol = "tcp"
  to_port     = 22
  from_port   = 22
  description = "Allow HTTPS traffic"
}

