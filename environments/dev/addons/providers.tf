provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = var.project_name
      State       = "addons"
    }
  }
}

provider "kubernetes" {
  host = data.terraform_remote_state.foundation.outputs.eks_cluster_endpoint

  cluster_ca_certificate = base64decode(
    data.terraform_remote_state.foundation.outputs.eks_cluster_certificate_authority_data
  )

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"

    args = [
      "eks",
      "get-token",
      "--cluster-name",
      data.terraform_remote_state.foundation.outputs.eks_cluster_name,
      "--region",
      var.aws_region,
      "--role-arn",
      data.terraform_remote_state.foundation.outputs.eks_access_entry_principal_arns["platform_admin"]
    ]
  }
}

provider "helm" {
  kubernetes = {
    host = data.terraform_remote_state.foundation.outputs.eks_cluster_endpoint

    cluster_ca_certificate = base64decode(
      data.terraform_remote_state.foundation.outputs.eks_cluster_certificate_authority_data
    )

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"

      args = [
        "eks",
        "get-token",
        "--cluster-name",
        data.terraform_remote_state.foundation.outputs.eks_cluster_name,
        "--region",
        var.aws_region,
        "--role-arn",
        data.terraform_remote_state.foundation.outputs.eks_access_entry_principal_arns["platform_admin"]
      ]
    }
  }
}