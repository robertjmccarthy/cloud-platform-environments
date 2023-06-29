
module "cccd_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.3.0"
  repo_name = "cccd"
  team_name = "laa-get-paid"

  providers = {
    aws = aws.london
  }

  oidc_providers      = ["circleci"]
  github_repositories = ["Claim-for-Crown-Court-Defence"]
  namespace           = var.namespace
}

resource "kubernetes_secret" "cccd_ecr_credentials" {
  metadata {
    name      = "cccd-ecr-credentials-output"
    namespace = "cccd-dev"
  }

  data = {
    access_key_id     = module.cccd_ecr_credentials.access_key_id
    secret_access_key = module.cccd_ecr_credentials.secret_access_key
    repo_arn          = module.cccd_ecr_credentials.repo_arn
    repo_url          = module.cccd_ecr_credentials.repo_url
  }
}
