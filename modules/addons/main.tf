data "aws_partition" "current" {}

locals {
  resource_name = "${var.name}-${var.environment}"

  common_tags = merge(
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Module      = "addons"
      Project     = var.name
    },
    var.tags
  )

  managed_addons = {
    coredns = {
      name    = "coredns"
      version = try(var.addon_versions["coredns"], null)
    }

    kube_proxy = {
      name    = "kube-proxy"
      version = try(var.addon_versions["kube-proxy"], null)
    }

    vpc_cni = {
      name    = "vpc-cni"
      version = try(var.addon_versions["vpc-cni"], null)
    }

    ebs_csi = {
      name    = "aws-ebs-csi-driver"
      version = try(var.addon_versions["aws-ebs-csi-driver"], null)
    }
  }
}
