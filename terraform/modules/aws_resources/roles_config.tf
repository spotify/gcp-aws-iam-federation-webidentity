#################################################################################
# Requirements
#################################################################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}
# Declare variables
variable "gcp_sa_display_name" {}
variable "gcp_sa_email" {}
variable "gcp_sa_unique_id" {}
variable "aws_iam_role_name" {
  default = "gcp_aws_federated_role"
}
#################################################################################
# Resources
#################################################################################
resource "aws_iam_role" "gcp_aws_federated_role" {
  name = var.aws_iam_role_name

  # Update this section with the trust policy
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "accounts.google.com"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "accounts.google.com:oaud": "GCP_federated_role_${var.aws_iam_role_name}",
            "accounts.google.com:email": var.gcp_sa_email,
            "accounts.google.com:sub": var.gcp_sa_unique_id
          }
        }
      },
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })

  tags = {
    tag-key = "test-tag"
  }
}

# Reference existing AWS IAM policy
data "aws_iam_policy" "AmazonEC2ReadOnlyAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}
# Assign the existing AWS IAM policy to your new role.
resource "aws_iam_role_policy_attachment" "amazon-readonly-role-policy-attach" {
  role       = "${aws_iam_role.gcp_aws_federated_role.name}"
  policy_arn = "${data.aws_iam_policy.AmazonEC2ReadOnlyAccess.arn}"
}
#################################################################################
# Outputs 
#################################################################################
output "aws_role_name" {
  value = aws_iam_role.gcp_aws_federated_role.name
}

output "aws_role_arn" {
  value = aws_iam_role.gcp_aws_federated_role.arn
}