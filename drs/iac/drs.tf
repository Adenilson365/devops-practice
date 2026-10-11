
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  availability_zone = "us-east-1a"
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

output "default_subnet_id" {
  value = data.aws_subnet.default.id
}

output "default_security_group_id" {
  value = data.aws_security_group.default.id
}

resource "aws_drs_replication_configuration_template" "default" {
  associate_default_security_group        = true
  auto_replicate_new_disks                = true
  bandwidth_throttling                    = 0
  create_public_ip                        = true
  data_plane_routing                      = "PUBLIC_IP"
  default_large_staging_disk_type         = "GP3"
  ebs_encryption                          = "DEFAULT"
  ebs_encryption_key_arn                  = null
  region                                  = var.region
  replication_server_instance_type        = var.replication_server_instance_type
  replication_servers_security_groups_ids = var.destroy ? tolist([data.aws_security_group.default.id]) : tolist([aws_security_group.staging.id])
  staging_area_subnet_id                  = var.destroy ? data.aws_subnet.default.id : aws_subnet.staging.id
  staging_area_tags = {}
  use_dedicated_replication_server        = false
  pit_policy {
    enabled            = true
    interval           = 10
    retention_duration = 60
    rule_id            = 1
    units              = "MINUTE"
  }
  pit_policy {
    enabled            = true
    interval           = 1
    retention_duration = 24
    rule_id            = 2
    units              = "HOUR"
  }
  pit_policy {
    enabled            = true
    interval           = 1
    retention_duration = 7
    rule_id            = 3
    units              = "DAY"
  }
}
