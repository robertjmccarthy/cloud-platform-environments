# generated by https://github.com/ministryofjustice/money-to-prisoners-deploy
module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.19.0"

  providers = {
    aws = aws.london
  }

  vpc_name = var.vpc_name

  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  namespace              = var.namespace
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support

  rds_family           = "postgres14"
  db_engine            = "postgres"
  db_engine_version    = "14.3"
  db_instance_class    = "db.m6g.xlarge"
  db_allocated_storage = "175"
  db_name              = "mtp_api"

  allow_major_version_upgrade  = false
  allow_minor_version_upgrade  = false
  deletion_protection          = true
  performance_insights_enabled = true
}

resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds"
    namespace = var.namespace
  }

  data = {
    db_identifier         = module.rds.db_identifier
    resource_id           = module.rds.resource_id
    rds_instance_endpoint = module.rds.rds_instance_endpoint
    database_name         = module.rds.database_name
    database_username     = module.rds.database_username
    database_password     = module.rds.database_password
    rds_instance_address  = module.rds.rds_instance_address
    rds_instance_port     = module.rds.rds_instance_port
    access_key_id         = module.rds.access_key_id
    secret_access_key     = module.rds.secret_access_key
  }
}
