


locals {
  drs_policies = {
    agent_installation = "arn:aws:iam::aws:policy/AWSElasticDisasterRecoveryAgentInstallationPolicy"
    agent_failback     = "arn:aws:iam::aws:policy/AWSElasticDisasterRecoveryFailbackInstallationPolicy"
  }
}

resource "aws_iam_role" "role01" {
  name = "drs-installer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowSSOAdministrator"
        Effect = "Allow"
        Action = "sts:AssumeRole"

        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:root"
        }

        Condition = {
          ArnLike = {
            "aws:PrincipalArn" = [
              "arn:aws:iam::${var.account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_*",
              "arn:aws:iam::${var.account_id}:role/aws-reserved/sso.amazonaws.com/*/AWSReservedSSO_AdministratorAccess_*"
            ]
          }
        }
      }
    ]
  })
  tags = {
    Name = "drs-installer-role"
    ManagedBy = "Terraform"
    Owner = "Adenilson"
  }
}

resource "aws_iam_role_policy_attachment" "drs_policies" {
  for_each = local.drs_policies

  role       = aws_iam_role.role01.name
  policy_arn = each.value
}