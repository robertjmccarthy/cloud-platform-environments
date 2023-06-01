module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=circleci"

  team_name = var.team_name
  repo_name = "oidc-test"

  github_repositories = ["cloud-platform-ecr-oidc-test"]

  oidc_providers = ["circleci"]
}