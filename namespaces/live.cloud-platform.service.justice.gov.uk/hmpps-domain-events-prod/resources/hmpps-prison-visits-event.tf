######################################## Prison visits event for visit someone in prison
######## hmpps-manage-prison-visits-orchestration service should listen to the configured queue (hmpps_prison_visits_event_queue)
######## for the given fevents (filter_policy configured below)!

######## TODO WE DO NOT SUBSCRIBE TO THE DOMAIN EVENTS QUEUE, as the code to consume this is not live
######## TODO HowTo namespaces/live.cloud-platform.service.justice.gov.uk/hmpps-domain-events-dev/resources/hmpps-prison-visits-event.tf

######## Main queue

module "hmpps_prison_visits_event_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                   = "hmpps_prison_visits_event_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.hmpps_prison_visits_event_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
EOF

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_prison_visits_event_queue" {
  ## For metadata use - not _
  metadata {
    name = "sqs-prison-visits-event-secret"
    ## Name space where the listening service is found
    namespace = "visit-someone-in-prison-backend-svc-prod"
  }

  data = {
    sqs_queue_url  = module.hmpps_prison_visits_event_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prison_visits_event_queue.sqs_arn
    sqs_queue_name = module.hmpps_prison_visits_event_queue.sqs_name
  }
}


######## Dead letter queue

module "hmpps_prison_visits_event_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "hmpps_prison_visits_event_dlq"
  encrypt_sqs_kms = "true"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_prison_visits_event_dead_letter_queue" {
  ## For metadata use - not _
  metadata {
    name = "sqs-prison-visits-event-dlq-secret"
    ## Name space where the listening service is found
    namespace = "visit-someone-in-prison-backend-svc-prod"
  }

  data = {
    sqs_queue_url  = module.hmpps_prison_visits_event_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prison_visits_event_dead_letter_queue.sqs_arn
    sqs_queue_name = module.hmpps_prison_visits_event_dead_letter_queue.sqs_name
  }
}
