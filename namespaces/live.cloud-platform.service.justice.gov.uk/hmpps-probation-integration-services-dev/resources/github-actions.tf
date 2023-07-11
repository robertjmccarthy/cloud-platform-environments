module "github_actions_service_account" {
  source = "github.com/marcus-bcl/cloud-platform-terraform-serviceaccount?ref=patch-1"

  namespace                            = var.namespace
  kubernetes_cluster                   = var.kubernetes_cluster
  serviceaccount_rules                 = var.serviceaccount_rules
  github_actions_secret_kube_cluster   = var.github_actions_secret_kube_cluster
  github_actions_secret_kube_namespace = var.github_actions_secret_kube_namespace
  github_actions_secret_kube_cert      = var.github_actions_secret_kube_cert
  github_actions_secret_kube_token     = var.github_actions_secret_kube_token
}

data "kubernetes_secret" "service_account_secret" {
  metadata {
    name      = module.github_actions_service_account.default_secret_name
    namespace = var.namespace
  }
}

resource "github_actions_environment_secret" "github_secrets" {
  for_each = {
    (var.github_actions_secret_kube_cluster)   = var.kubernetes_cluster
    (var.github_actions_secret_kube_namespace) = var.namespace
    (var.github_actions_secret_kube_cert)      = lookup(data.kubernetes_secret.service_account_secret.data, "ca.crt")
    (var.github_actions_secret_kube_token)     = lookup(data.kubernetes_secret.service_account_secret.data, "token")
  }
  repository      = "hmpps-probation-integration-services"
  environment     = var.github_environment
  secret_name     = each.key
  plaintext_value = each.value
}
