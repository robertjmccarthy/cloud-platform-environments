module "ingress_controller" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-teams-ingress-controller?ref=0.1.0"

  namespace     = "keyworker-api-prod"
  is_production = var.is-production
}