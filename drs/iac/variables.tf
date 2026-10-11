variable "account_id" {
  type        = string
  description = "The ID of the AWS account to assume the role"  
}

variable "region" {
  type        = string
  description = "The AWS region to deploy resources in"
}

variable "replication_server_instance_type" {
  type        = string
  description = "The instance type for the replication server"
}
variable "destroy" {
  type        = bool
  description = "Flag to indicate if resources should be destroyed"
  default     = false
}
