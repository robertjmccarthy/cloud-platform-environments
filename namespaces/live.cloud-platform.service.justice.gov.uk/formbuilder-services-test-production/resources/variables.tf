variable "environment-name" {
  default = "test-production"
}

variable "team_name" {
  default = "formbuilder"
}

variable "is_production" {
  default = "false"
}

variable "infrastructure_support" {
  default = "Form Builder form-builder-developers@digital.justice.gov.uk"
}

# The following variable is provided at runtime by the pipeline.

variable "vpc_name" {
}

variable "eks_cluster_name" {
}

variable "namespace" {
  default = "formbuilder-services-test-production"
}

variable "business_unit" {
  default = "Services"
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

