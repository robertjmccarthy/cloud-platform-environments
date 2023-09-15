module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "hale-platform-staging-service"
  namespace            = var.namespace # this is also used as a tag

  # Attach the approprate policies using a key => value map
  # If you're using Cloud Platform provided modules (e.g. SNS, S3), these
  # provide an output called `irsa_policy_arn` that can be used.
  role_policy_arns = {
    s3 = module.s3_bucket.irsa_policy_arn
    s3_x_bucket_policy = aws_iam_policy.s3_x_bucket_policy.arn,
    ecr = module.ecr_credentials.irsa_policy_arn,
    ecr2 = module.ecr_feed_parser.irsa_policy_arn,
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support 
 }

  data "aws_iam_policy_document" "s3_x_bucket_policy" {
    # Provide list of permissions and target AWS account resources to allow access to
    statement {
      actions = [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:PutObjectTagging"
      ]
      resources = var.bucket_arns
    }
  }

  # Policy allowing us to move objects between namespace buckets and external AWS accounts
  resource "aws_iam_policy" "s3_x_bucket_policy" {
    name   = "s3_x_bucket_policy"
    policy = data.aws_iam_policy_document.s3_x_bucket_policy.json

    tags = {
      business_unit          = var.business_unit
      application            = var.application
      is_production          = var.is_production
      team_name              = var.team_name
      environment_name       = var.environment
      infrastructure_support = var.infrastructure_support
      }
  }

  resource "kubernetes_secret" "s3_x_bucket_secret" {
    metadata {
    name      = "s3-bucket-x-access-allowlist"
    namespace = var.namespace
  }

  data = {
    bucket_arn = var.bucket_arns
  }
}