data "terraform_remote_state" "foundation" {
  backend = "s3"

  config = {
    bucket  = var.foundation_state_bucket
    key     = var.foundation_state_key
    region  = var.aws_region
    encrypt = true

    use_lockfile = true
  }
}

module "addons" {
  source = "../../../modules/addons"

  name         = var.project_name
  environment  = var.environment
  cluster_name = data.terraform_remote_state.foundation.outputs.eks_cluster_name

  addon_versions = var.addon_versions

  external_dns_hosted_zone_ids = var.external_dns_hosted_zone_ids

  external_secrets_secret_arns  = var.external_secrets_secret_arns
  external_secrets_kms_key_arns = var.external_secrets_kms_key_arns

  tags = var.tags
}