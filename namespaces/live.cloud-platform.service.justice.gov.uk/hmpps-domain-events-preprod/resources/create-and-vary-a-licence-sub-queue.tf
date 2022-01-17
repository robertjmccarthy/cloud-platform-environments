module "create_and_vary_a_licence_domain_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.5"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "create_and_vary_a_licence_domain_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.create_and_vary_a_licence_domain_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  providers = {
    aws = aws.london
  }
}

module "create_and_vary_a_licence_domain_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.5"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "create_and_vary_a_licence_domain_events_queue_dl"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "create_and_vary_a_licence_domain_events_queue_policy" {
  queue_url = module.create_and_vary_a_licence_domain_events_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.create_and_vary_a_licence_domain_events_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.create_and_vary_a_licence_domain_events_queue.sqs_arn}",
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

resource "aws_sns_topic_subscription" "create_and_vary_a_licence_domain_events_subscription" {
  provider      = aws.london
  topic_arn     = module.hmpps-domain-events.topic_arn
  protocol      = "sqs"
  endpoint      = module.create_and_vary_a_licence_domain_events_queue.sqs_arn
  filter_policy = "{\"eventType\":[\"prison-offender-events.prisoner.released\", \"prison-offender-events.prisoner.received\"]}"
}

resource "kubernetes_secret" "create_and_vary_a_licence_domain_events_queue" {
  metadata {
    name      = "create-and-vary-a-licence-domain-events-sqs-instance-output"
    namespace = "create-and-vary-a-licence-preprod"
  }

  data = {
    access_key_id     = module.create_and_vary_a_licence_domain_events_queue.access_key_id
    secret_access_key = module.create_and_vary_a_licence_domain_events_queue.secret_access_key
    sqs_id            = module.create_and_vary_a_licence_domain_events_queue.sqs_id
    sqs_arn           = module.create_and_vary_a_licence_domain_events_queue.sqs_arn
    sqs_name          = module.create_and_vary_a_licence_domain_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "create_and_vary_a_licence_domain_events_dead_letter_queue" {
  metadata {
    name      = "create-and-vary-a-licence-domain-events-sqs-dl-instance-output"
    namespace = "create-and-vary-a-licence-preprod"
  }

  data = {
    access_key_id     = module.create_and_vary_a_licence_domain_events_dead_letter_queue.access_key_id
    secret_access_key = module.create_and_vary_a_licence_domain_events_dead_letter_queue.secret_access_key
    sqs_id            = module.create_and_vary_a_licence_domain_events_dead_letter_queue.sqs_id
    sqs_arn           = module.create_and_vary_a_licence_domain_events_dead_letter_queue.sqs_arn
    sqs_name          = module.create_and_vary_a_licence_domain_events_dead_letter_queue.sqs_name
  }
}
