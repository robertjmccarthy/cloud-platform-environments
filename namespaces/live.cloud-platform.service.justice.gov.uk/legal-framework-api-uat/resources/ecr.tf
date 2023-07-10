module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.3.0"

  team_name           = var.team_name
  repo_name           = "${var.namespace}-ecr"
  oidc_providers      = ["circleci"]
  github_repositories = [var.repo_name]
  namespace           = var.namespace
}

resource "kubernetes_secret" "ecr-repo" {
  metadata {
    name      = "ecr-repo-${var.namespace}"
    namespace = var.namespace
  }

  data = {
    repo_url          = module.ecr-repo.repo_url
    access_key_id     = module.ecr-repo.access_key_id
    secret_access_key = module.ecr-repo.secret_access_key
  }
}
