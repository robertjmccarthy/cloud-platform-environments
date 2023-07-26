resource "aws_sns_topic_subscription" "hmpps_prisoner_to_nomis_adjudication_subscription" {
  provider      = aws.london
  topic_arn     = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol      = "sqs"
  endpoint      = module.hmpps_prisoner_to_nomis_adjudication_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "adjudication.report.created"
    ]
  })
}

module "hmpps_prisoner_to_nomis_adjudication_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name          = var.environment
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure_support
  application               = var.application
  sqs_name                  = "hmpps_prisoner_to_nomis_adjudication_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.hmpps_prisoner_to_nomis_adjudication_dead_letter_queue.sqs_arn
    maxReceiveCount     = 3
  })

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "hmpps_prisoner_to_nomis_adjudication_queue_policy" {
  queue_url = module.hmpps_prisoner_to_nomis_adjudication_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.hmpps_prisoner_to_nomis_adjudication_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.hmpps_prisoner_to_nomis_adjudication_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": "${data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value}"
                          }
                        }
        }
      ]
  }

EOF

}

module "hmpps_prisoner_to_nomis_adjudication_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name       = var.environment
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "hmpps_prisoner_to_nomis_adjudication_dead_letter_queue"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_prisoner_to_nomis_adjudication_queue" {
  metadata {
    name      = "sqs-nomis-update-adjudication-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_prisoner_to_nomis_adjudication_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prisoner_to_nomis_adjudication_queue.sqs_arn
    sqs_queue_name = module.hmpps_prisoner_to_nomis_adjudication_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_prisoner_to_nomis_adjudication_dead_letter_queue" {
  metadata {
    name      = "sqs-nomis-update-adjudication-dlq-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_prisoner_to_nomis_adjudication_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prisoner_to_nomis_adjudication_dead_letter_queue.sqs_arn
    sqs_queue_name = module.hmpps_prisoner_to_nomis_adjudication_dead_letter_queue.sqs_name
  }
}

data "aws_ssm_parameter" "hmpps-domain-events-topic-arn" {
  name = "/hmpps-domain-events-dev/topic-arn"
}