

module "prison_to_probation_update_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.5"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "prison_to_probation_update_hmpps_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.prison_to_probation_update_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }

EOF


  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "prison_to_probation_update_queue_policy" {
  queue_url = module.prison_to_probation_update_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.prison_to_probation_update_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.prison_to_probation_update_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": "${module.hmpps-domain-events.topic_arn}"
                          }
                        }
        }
      ]
  }

EOF

}

module "prison_to_probation_update_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.5"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "prison_to_probation_update_hmpps_dlq"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "prison_to_probation_update_queue" {
  metadata {
    name      = "sqs-hmpps-domain-events-prison-to-probation-update"
    namespace = var.namespace
    # Remove when namespace has been migrated
    # name      = "sqs-hmpps-domain-events"
    # namespace = "prison-to-probation-update-prod"
  }

  data = {
    access_key_id     = module.prison_to_probation_update_queue.access_key_id
    secret_access_key = module.prison_to_probation_update_queue.secret_access_key
    sqs_queue_url     = module.prison_to_probation_update_queue.sqs_id
    sqs_queue_arn     = module.prison_to_probation_update_queue.sqs_arn
    sqs_queue_name    = module.prison_to_probation_update_queue.sqs_name
  }
}

resource "kubernetes_secret" "prison_to_probation_update_dlq" {
  metadata {
    name      = "sqs-hmpps-domain-events-dlq-prison-to-probation-update"
    namespace = var.namespace
    # Remove when namespace has been migrated
    # name      = "sqs-hmpps-domain-events-dlq"
    # namespace = "prison-to-probation-update-prod"
  }

  data = {
    access_key_id     = module.prison_to_probation_update_dead_letter_queue.access_key_id
    secret_access_key = module.prison_to_probation_update_dead_letter_queue.secret_access_key
    sqs_queue_url     = module.prison_to_probation_update_dead_letter_queue.sqs_id
    sqs_queue_arn     = module.prison_to_probation_update_dead_letter_queue.sqs_arn
    sqs_queue_name    = module.prison_to_probation_update_dead_letter_queue.sqs_name
  }
}


resource "aws_sns_topic_subscription" "prison_to_probation_update_subscription" {
  provider      = aws.london
  topic_arn     = module.hmpps-domain-events.topic_arn
  protocol      = "sqs"
  endpoint      = module.prison_to_probation_update_queue.sqs_arn
  filter_policy = "{\"eventType\":[\"prison-offender-events.prisoner.released\", \"prison-offender-events.prisoner.received\"]}"
}


