resource "local_file" "file" {
  content  = var.file_content
  filename = "${path.module}/hello.txt"
  
}


variable "file_content" {
  description = "Content to be written to the file"
  type        = string
  default     = "Hello, World!"
  sensitive   = true
}

ephemeral "random_password" "db_password" {
  length           = 16
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "db_password" {
  name = "db_password"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id                = aws_secretsmanager_secret.db_password.id
  secret_string_wo         = ephemeral.random_password.db_password.result
  secret_string_wo_version = 2
}