mock_provider "aws" {
  override_during = plan

  mock_resource "aws_kms_key" {
    defaults = {
      arn    = "arn:aws:kms:us-east-1:123456789012:key/test-key"
      key_id = "test-key"
    }
  }
}

run "secure_eks_control_plane" {
  command = plan

  variables {
    name               = "three-tier-eks"
    environment        = "dev"
    kubernetes_version = "1.33"

    cluster_role_arn = "arn:aws:iam::123456789012:role/three-tier-eks-dev-cluster-role"

    subnet_ids = [
      "subnet-0123456789abcdef0",
      "subnet-0123456789abcdef1",
      "subnet-0123456789abcdef2"
    ]

    tags = {
      Owner = "platform-engineering"
    }
  }

  assert {
    condition     = aws_eks_cluster.this.name == "three-tier-eks-dev"
    error_message = "The EKS cluster name is incorrect."
  }

  assert {
    condition = (
      aws_eks_cluster.this.role_arn ==
      var.cluster_role_arn
    )

    error_message = "The EKS cluster must use the supplied cluster IAM role."
  }

  assert {
    condition     = aws_eks_cluster.this.version == "1.33"
    error_message = "The EKS cluster must use the configured Kubernetes version."
  }

  assert {
    condition = (
      length(aws_eks_cluster.this.vpc_config[0].subnet_ids) == 3
    )

    error_message = "The EKS cluster must use all three supplied private subnets."
  }

  assert {
    condition     = aws_eks_cluster.this.vpc_config[0].endpoint_private_access
    error_message = "The private Kubernetes API endpoint must be enabled."
  }

  assert {
    condition     = !aws_eks_cluster.this.vpc_config[0].endpoint_public_access
    error_message = "The public Kubernetes API endpoint must be disabled by default."
  }

  assert {
    condition = (
      aws_eks_cluster.this.enabled_cluster_log_types ==
      toset([
        "api",
        "audit",
        "authenticator",
        "controllerManager",
        "scheduler"
      ])
    )

    error_message = "All EKS control-plane log types must be enabled."
  }

  assert {
    condition     = aws_eks_cluster.this.deletion_protection
    error_message = "EKS deletion protection must be enabled by default."
  }

  assert {
    condition = (
      aws_eks_cluster.this.access_config[0].authentication_mode ==
      "API"
    )

    error_message = "The EKS cluster must use API authentication by default."
  }

  assert {
    condition = (
      !aws_eks_cluster.this.access_config[0].bootstrap_cluster_creator_admin_permissions
    )

    error_message = "The cluster creator must not receive permanent administrator access."
  }

  assert {
    condition = (
      aws_eks_cluster.this.encryption_config[0].resources ==
      toset(["secrets"])
    )

    error_message = "Kubernetes secrets must be encrypted with KMS."
  }

  assert {
    condition     = aws_kms_key.cluster.enable_key_rotation
    error_message = "The Kubernetes secrets KMS key must enable automatic rotation."
  }

  assert {
    condition = (
      aws_kms_key.cluster.deletion_window_in_days ==
      var.kms_deletion_window_days
    )

    error_message = "The KMS key must use the configured deletion window."
  }

  assert {
    condition     = aws_eks_cluster.this.tags["Module"] == "eks-cluster"
    error_message = "The EKS cluster must include the module tag."
  }

  assert {
    condition     = aws_eks_cluster.this.tags["Owner"] == "platform-engineering"
    error_message = "Additional tags must be applied to the EKS cluster."
  }
}