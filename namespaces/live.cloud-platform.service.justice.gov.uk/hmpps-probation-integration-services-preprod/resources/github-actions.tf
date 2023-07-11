module "github_actions_service_account" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.8.2"

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
    SERVICE_POD_NAME                           = module.github_actions_service_pod.pod_name
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

# A long-running service pod for running AWS CLI commands from GitHub Actions
module "github_actions_service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.0.0"

  # Configuration
  namespace            = var.namespace
  service_account_name = module.shared-service-account.service_account.name
}

resource "kubernetes_role" "github_actions_service_pod_role" {
  metadata {
    name      = "github-actions-service-pod-role"
    namespace = var.namespace
  }
  rule {
    api_groups = ["*"]
    resources  = ["pods/exec", "pods/attach"]
    verbs = [
      "create",
      "delete",
      "get",
      "list",
      "patch",
      "update",
      "watch",
    ]
    resource_names = [module.github_actions_service_pod.pod_name]
  }
  rule {
    api_groups     = ["*"]
    resources      = ["pods/logs"]
    verbs          = ["get"]
    resource_names = [module.github_actions_service_pod.pod_name]
  }
}

resource "kubernetes_role_binding" "github-actions-rolebinding" {
  metadata {
    name      = "github-actions-service-pod-rolebinding"
    namespace = var.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.github_actions_service_pod_role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = module.github_actions_service_account.service_account.name
    namespace = var.namespace
  }
}
