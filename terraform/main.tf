########################################################################
# Define modules
########################################################################
module "aws_resources" {
    source               = "./modules/aws_resources"
    gcp_sa_display_name  = module.gcp_resources.gcp_sa_display_name
    gcp_sa_email         = module.gcp_resources.gcp_sa_email
    gcp_sa_unique_id     = module.gcp_resources.gcp_sa_unique_id
    
    providers = {
      aws = aws.aws
    }
}

module "gcp_resources" {
    source      = "./modules/gcp_resources"
    gcp_pid     = var.gcp_pid
    gcp_zone    = var.zone
    gcp_region  = var.region
    gcp_iam_groups_to_grant_to_service_account = var.gcp_iam_groups_to_grant_to_service_account

    providers = {
      google = google.gcp
    }
}
########################################################################
# Define providers
########################################################################
data "google_client_config" "default" {}

provider "google" {
  alias   = "gcp"
  project = var.gcp_pid
  region  = var.region
  zone    = var.zone
}

provider "aws" {
  alias   = "aws"
  region  = var.aws_region
}
########################################################################
# Define variables
########################################################################
variable "gcp_pid" {
   type        = string
   description = "GCP project."
}

variable "aws_pid" {
   type        = string
   description = "AWS account ID."
}

variable "gcp_iam_groups_to_grant_to_service_account" {
  type        = string
  description = "The IAM groups you want to be able to have access to the GCP service account."
}

variable "zone" {
   type        = string
   description = "GCP zone in the var.region where resources are created."
   default = "europe-west1-b"
}

variable "region" {
   type        = string
   description = "GCP region where resources are created."
   default = "europe-west1"
}

variable "aws_region" {
   type        = string
   description = "GCP region where resources are created."
   default = "eu-west-1"
}
########################################################################
# Define outputs
########################################################################
output "gcp_project" {
  value = var.gcp_pid
}

output "aws_account" {
  value = var.aws_pid
}

output "gcp_sa_email" {
  value = module.gcp_resources.gcp_sa_email
}

output "gcp_sa_display_name" {
  value = module.gcp_resources.gcp_sa_display_name
}

output "aws_role" {
  value = module.aws_resources.aws_role_name
}

output "aws_role_arn" {
  value = module.aws_resources.aws_role_arn
}

output "gcp_sa_unique_id" {
  value = module.gcp_resources.gcp_sa_unique_id
}
