variable "application" {
  default = "laa-court-data-ui"
}

variable "namespace" {
  default = "laa-court-data-ui-staging"
}

variable "domain" {
  default = "view-court-data.service.justice.gov.uk"
}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "legal-aid-agency"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "laa-assess-a-claim"
}

variable "repo_name" {
  description = "The name of github repo AND ecr repo"
  default     = "laa-court-data-ui"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "staging"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "assessaclaim@digital.justice.gov.uk"
}

variable "is-production" {
  default = "false"
}

/*
 * When using this module through the cloud-platform-environments, the following
 * two variables are automatically supplied by the pipeline.
 *
 */
variable "cluster_name" {
}


