/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 *
 */
variable "vpc_name" {
}

variable "namespace" {
  default = "claim-criminal-injuries-compensation-prod"
}

variable "business_unit" {
  default = "cica"
}

variable "team_name" {
  default = "cica-dev-team"
}

variable "application" {
  default = "claim-criminal-injuries-compensation-prod"
}

variable "email" {
  default = "Infrastructure@cica.gov.uk"
}

variable "environment-name" {
  default = "prod"
}

variable "is_production" {
  default = "true"
}

variable "domain" {
  default = "claim-criminal-injuries-compensation.service.justice.gov.uk"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email"
  default     = "Infrastructure@cica.gov.uk"
}

variable "db_backup_retention_period" {
  description = "The days to retain backup jobs. Must be 1 or greater to be a source for a Read Replica"
  default     = "35"
}

# For Push gateway
variable "service_monitor" {
  description = "If true, prometheus will automatically scrape"
  default     = true
}
variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider. See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials"
  type        = string
  default     = "ministryofjustice"
}

variable "github_token" {
  type        = string
  description = "Required by the GitHub Terraform provider"
  default     = ""
}

