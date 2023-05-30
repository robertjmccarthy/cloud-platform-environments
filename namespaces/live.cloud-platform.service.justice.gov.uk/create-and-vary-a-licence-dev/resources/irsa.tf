
# Add the names of the SQS which the app needs permissions to access.
# The value of each item should be the namespace where the SQS was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  sqs_queues = {
    "Digital-Prison-Services-dev-cvl_domain_events_queue"       = "hmpps-domain-events-dev",
    "Digital-Prison-Services-dev-cvl_domain_events_queue_dl"    = "hmpps-domain-events-dev",
    "Digital-Prison-Services-dev-cvl_probation_events_queue"    = "offender-events-dev",
    "Digital-Prison-Services-dev-cvl_probation_events_queue_dl" = "offender-events-dev",
    "Digital-Prison-Services-dev-cvl_prison_events_queue"       = "offender-events-dev",
    "Digital-Prison-Services-dev-cvl_prison_events_queue_dl"    = "offender-events-dev"
  }
}

module "app-irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=1.1.0"

  eks_cluster_name = var.eks_cluster_name
  namespace        = var.namespace
  service_account  = "${var.application}-${var.environment}"
  role_policy_arns = [for item in data.aws_ssm_parameter.irsa_policy_arns : item.value]
}

data "aws_ssm_parameter" "irsa_policy_arns" {
  for_each = local.sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}
