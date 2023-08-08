module "manage_intelligence_extractor_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.8.2"
  team_name              = var.team_name
  acl                    = "private"
  versioning             = false
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

module "manage_intelligence_transformer_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.8.2"
  team_name              = var.team_name
  acl                    = "private"
  versioning             = false
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ims_extractor_s3_bucket" {
  metadata {
    name      = "ims-extractor-s3-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn        = module.manage_intelligence_extractor_bucket.bucket_arn
    bucket_name       = module.manage_intelligence_extractor_bucket.bucket_name
  }
}

resource "kubernetes_secret" "ims_transformer_s3_bucket" {
  metadata {
    name      = "ims-transformer-s3-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn        = module.manage_intelligence_transformer_bucket.bucket_arn
    bucket_name       = module.manage_intelligence_transformer_bucket.bucket_name
  }
}