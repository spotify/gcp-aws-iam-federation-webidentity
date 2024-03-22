#################################################################################
#################################################################################
# Project: Put your GCP project here
#################################################################################
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
    }
  }
}
#################################################################################
resource "google_service_account" "federation-nonprod-workload-sa" {
  # Description: Service account used to tag resources in other projects.
  # docs: https://cloud.google.com/iam/docs/impersonating-service-accounts#iam-service-accounts-grant-role-sa-gcloud
  account_id   = "federation-nonprod-workload-sa"
  project      = var.gcp_pid
  display_name = "federation-nonprod-workload-sa"
  description = "A service account to enable workload identity federation between GCP projects and AWS accounts."
}
#################################################################################
variable "roles_to_grant_to_service_account" {
  # Description: These are the roles we want to grant to service account
  description = "IAM roles to grant to the service account"
  type        = list(string)
  # The below roles are all the permissions that we want the service account to have.
  default = [
    "roles/storage.admin",
    "roles/compute.instanceAdmin.v1", # This is needed to grant the compute.images.create permission. https://cloud.google.com/compute/docs/reference/rest/v1/images/insert
    "roles/iam.serviceAccountTokenCreator" # This is needed if we want the Service Account to be able to create OpenID Connect ID or other tokens
  ]
}
#################################################################################
variable "roles_to_grant_to_service_account_members" {
  # Description: These are the roles we want to grant to members of service account
  # As an owner of this project, all members will inherit the - iam.serviceAccounts.actAs
  # for any service account in this project. Hence the below statement isn't needed.
  description = "IAM roles to grant to the service account members"
  type        = list(string)
  default = [
    "roles/iam.serviceAccountUser", # Lets a user impersonate a service account. https://cloud.google.com/iam/docs/service-accounts
    "roles/iam.serviceAccountTokenCreator" #This is the role needed on the service account to let the user impersonate the service account and issue tokens.
  ]
}
#################################################################################
resource "google_project_iam_binding" "roles_to_grant_to_service_account" {
  # Description: Creates IAM bindings (IAM Policy) for all roles related to the service account
  project            = var.gcp_pid
  members = [
    "serviceAccount:${google_service_account.federation-nonprod-workload-sa.email}",
  ]
  for_each = toset(var.roles_to_grant_to_service_account)
  role     = each.value
}
##################################################################################
resource "google_project_iam_binding" "roles_to_grant_to_service_account_members" {
  # Description: Creates IAM bindings (IAM Policy) for all roles related to members of the service account
  project            = var.gcp_pid
  members            = [ 
    "group:${var.gcp_iam_groups_to_grant_to_service_account}"
    ]
  for_each = toset(var.roles_to_grant_to_service_account_members)
  role     = each.value
}
#################################################################################
# Variables
#################################################################################
variable "gcp_pid" {}

variable "gcp_region" {}

variable "gcp_zone" {}
   
variable "gcp_iam_groups_to_grant_to_service_account" {}
#################################################################################
# Outputs 
#################################################################################
output "gcp_sa_display_name" {
  value = google_service_account.federation-nonprod-workload-sa.display_name
}

output "gcp_sa_email" {
  value = google_service_account.federation-nonprod-workload-sa.email
}

output "gcp_sa_unique_id" {
  value = google_service_account.federation-nonprod-workload-sa.unique_id
}